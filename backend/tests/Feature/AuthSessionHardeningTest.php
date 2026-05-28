<?php

namespace Tests\Feature;

use App\Models\Branch;
use App\Models\Shift;
use App\Models\Staff;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;
use Tests\TestCase;

class AuthSessionHardeningTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_stores_device_metadata_and_revokes_same_device_sessions(): void
    {
        config([
            'sanctum.expiration' => 60,
            'auth_sessions.revoke_same_device_tokens' => true,
        ]);

        $user = User::factory()->create([
            'password' => 'password123',
            'role' => 'admin',
            'status' => 'Active',
        ]);

        $firstToken = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'password123',
            'device_name' => 'iPhone 15',
            'device_id' => 'ios-1',
        ])->assertOk()->json('access_token');

        $secondToken = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'password123',
            'device_name' => 'iPhone 15',
            'device_id' => 'ios-1',
        ])->assertOk()
            ->assertJsonPath('session.device_name', 'iPhone 15')
            ->assertJsonPath('session.device_id', 'ios-1')
            ->json('access_token');

        $this->assertNotSame($firstToken, $secondToken);
        $this->assertDatabaseCount('personal_access_tokens', 1);
        $this->assertDatabaseHas('personal_access_tokens', [
            'tokenable_id' => $user->id,
            'device_name' => 'iPhone 15',
            'device_id' => 'ios-1',
        ]);
        $this->assertNotNull(PersonalAccessToken::query()->first()?->expires_at);
    }

    public function test_logout_revokes_only_the_current_session(): void
    {
        $user = User::factory()->create([
            'password' => 'password123',
        ]);
        $phoneSession = $user->createToken('phone');
        $desktopSession = $user->createToken('desktop');

        $this->withToken($phoneSession->plainTextToken)
            ->postJson('/api/auth/logout')
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $phoneSession->accessToken->getKey(),
        ]);
        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $desktopSession->accessToken->getKey(),
        ]);
    }

    public function test_logout_all_revokes_every_session(): void
    {
        $user = User::factory()->create([
            'password' => 'password123',
        ]);
        $phoneSession = $user->createToken('phone');
        $user->createToken('desktop');

        $this->withToken($phoneSession->plainTextToken)
            ->postJson('/api/auth/logout-all')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('revoked_sessions', 2);

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_change_password_updates_password_and_revokes_other_devices(): void
    {
        $user = User::factory()->create([
            'password' => 'password123',
            'role' => 'admin',
            'status' => 'Active',
        ]);
        $currentSession = $user->createToken('phone');
        $otherSession = $user->createToken('desktop');

        $this->withToken($currentSession->plainTextToken)
            ->postJson('/api/auth/change-password', [
                'current_password' => 'password123',
                'password' => 'NewPassword123!',
                'password_confirmation' => 'NewPassword123!',
            ])
            ->assertOk()
            ->assertJsonPath('success', true);

        $user->refresh();

        $this->assertTrue(Hash::check('NewPassword123!', $user->password));
        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $currentSession->accessToken->getKey(),
        ]);
        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $otherSession->accessToken->getKey(),
        ]);

        $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'password123',
        ])->assertUnauthorized();

        $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'NewPassword123!',
        ])->assertOk();
    }

    public function test_inactive_accounts_cannot_sign_in(): void
    {
        $user = User::factory()->create([
            'password' => 'password123',
            'role' => 'staff',
            'status' => 'Suspended',
        ]);

        $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'password123',
            'device_id' => 'ios-1',
        ])->assertForbidden()
            ->assertJsonPath('message', 'This account is not active. Contact your administrator.');

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_staff_login_binds_the_first_device_and_rejects_other_devices(): void
    {
        $user = User::factory()->create([
            'password' => 'password123',
            'role' => 'staff',
            'status' => 'Active',
            'device_id' => null,
        ]);

        $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'password123',
            'device_name' => 'iPhone 15',
            'device_id' => 'ios-1',
        ])->assertOk();

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'device_id' => 'ios-1',
        ]);

        $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'password123',
            'device_name' => 'Pixel 9',
            'device_id' => 'android-2',
        ])->assertForbidden()
            ->assertJsonPath(
                'message',
                'Your account is bound to a different device. Contact admin to reset device binding.'
            );
    }

    public function test_inactive_authenticated_users_are_blocked_from_protected_routes(): void
    {
        $user = User::factory()->create([
            'status' => 'Inactive',
            'role' => 'admin',
        ]);
        $session = $user->createToken('desktop');

        $this->withToken($session->plainTextToken)
            ->getJson('/api/auth/me')
            ->assertForbidden()
            ->assertJsonPath('message', 'This account is not active. Contact your administrator.');

        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $session->accessToken->getKey(),
        ]);
    }

    public function test_staff_session_restore_fails_when_token_device_does_not_match_bound_device(): void
    {
        $user = User::factory()->create([
            'role' => 'staff',
            'status' => 'Active',
            'device_id' => 'ios-1',
        ]);
        $session = $user->createToken('phone');
        $session->accessToken->forceFill([
            'device_id' => 'ios-2',
        ])->save();

        $this->withToken($session->plainTextToken)
            ->getJson('/api/auth/me')
            ->assertUnauthorized()
            ->assertJsonPath('message', 'Your session is no longer valid on this device. Please sign in again.');

        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $session->accessToken->getKey(),
        ]);
    }

    public function test_admin_can_reset_staff_device_binding_and_revoke_staff_sessions(): void
    {
        [$branch, $shift] = $this->seedBranchAndShift('b001', 's001');
        $admin = User::factory()->create([
            'role' => 'admin',
            'status' => 'Active',
        ]);
        $adminSession = $admin->createToken('desktop');

        $staffUser = User::factory()->create([
            'role' => 'staff',
            'status' => 'Active',
            'device_id' => 'ios-1',
        ]);
        $staffSession = $staffUser->createToken('phone');
        $staffSession->accessToken->forceFill([
            'device_id' => 'ios-1',
        ])->save();

        $staff = Staff::query()->create([
            'id' => 'st001',
            'user_id' => $staffUser->id,
            'staff_code' => 'SHR-001',
            'name' => 'Reset Candidate',
            'email' => $staffUser->email,
            'mobile' => $staffUser->mobile ?? '+96890000000',
            'job_title' => 'Driver',
            'category' => 'Driver',
            'department' => 'Operations',
            'branch_id' => $branch->id,
            'branch_name' => $branch->branch_name,
            'shift_id' => $shift->id,
            'shift_name' => $shift->shift_name,
            'joining_date' => now(),
            'basic_salary' => 300,
            'overtime_rate' => 2,
            'weekly_off_day' => 'Friday',
            'status' => 'Active',
        ]);

        $this->withToken($adminSession->plainTextToken)
            ->postJson("/api/staff/{$staff->id}/reset-device-binding")
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseHas('users', [
            'id' => $staffUser->id,
            'device_id' => null,
        ]);
        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $staffSession->accessToken->getKey(),
        ]);
        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $adminSession->accessToken->getKey(),
        ]);
    }

    public function test_login_endpoint_is_rate_limited_after_configured_attempts(): void
    {
        config([
            'auth_sessions.login_throttle_max_attempts' => 2,
        ]);

        $user = User::factory()->create([
            'password' => 'password123',
            'status' => 'Active',
        ]);

        $payload = [
            'email' => $user->email,
            'password' => 'wrong-password',
        ];

        $this->postJson('/api/auth/login', $payload)->assertUnauthorized();
        $this->postJson('/api/auth/login', $payload)->assertUnauthorized();
        $this->postJson('/api/auth/login', $payload)
            ->assertStatus(429)
            ->assertJsonStructure(['message', 'retry_after_seconds']);
    }

    public function test_authenticated_user_can_issue_and_revoke_biometric_tokens(): void
    {
        $user = User::factory()->create([
            'role' => 'staff',
            'status' => 'Active',
            'device_id' => 'ios-1',
        ]);
        $session = $user->createToken('iPhone 15');
        $session->accessToken->forceFill([
            'device_name' => 'iPhone 15',
            'device_id' => 'ios-1',
        ])->save();

        $response = $this->withToken($session->plainTextToken)
            ->postJson('/api/auth/biometric-token')
            ->assertOk()
            ->assertJsonPath('session.device_id', 'ios-1');

        $biometricToken = PersonalAccessToken::query()
            ->where('tokenable_id', $user->id)
            ->where('name', 'like', 'biometric:%')
            ->first();

        $this->assertNotNull($biometricToken);
        $this->assertNotSame(
            $response->json('access_token'),
            $session->plainTextToken,
        );

        $this->withToken($session->plainTextToken)
            ->deleteJson('/api/auth/biometric-token')
            ->assertOk();

        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $biometricToken?->getKey(),
        ]);
        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $session->accessToken->getKey(),
        ]);
    }

    public function test_admin_created_staff_receives_generated_temporary_password_and_server_id(): void
    {
        [$branch, $shift] = $this->seedBranchAndShift();
        $admin = User::factory()->create([
            'role' => 'admin',
            'status' => 'Active',
        ]);
        $session = $admin->createToken('desktop');

        $response = $this->withToken($session->plainTextToken)
            ->postJson('/api/staff', [
                'staff' => [
                    'id' => '',
                    'user_id' => '',
                    'staff_code' => '',
                    'name' => 'Generated Staff',
                    'email' => 'generated.staff@example.com',
                    'mobile' => '+96890000001',
                    'job_title' => 'Driver',
                    'category' => 'Driver',
                    'department' => 'Operations',
                    'branch_id' => $branch->id,
                    'branch_name' => $branch->branch_name,
                    'shift_id' => $shift->id,
                    'shift_name' => $shift->shift_name,
                    'joining_date' => now()->toIso8601String(),
                    'basic_salary' => 325,
                    'overtime_rate' => 2,
                    'weekly_off_day' => 'Friday',
                    'status' => 'Active',
                ],
                'user' => [
                    'name' => 'Generated Staff',
                    'email' => 'generated.staff@example.com',
                    'mobile' => '+96890000001',
                    'role' => 'staff',
                    'status' => 'Active',
                ],
            ])
            ->assertCreated()
            ->assertJsonStructure(['id', 'staff_code', 'temporary_password']);

        $temporaryPassword = $response->json('temporary_password');
        $this->assertIsString($temporaryPassword);
        $this->assertNotSame('password123', $temporaryPassword);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i',
            $response->json('id'),
        );
        $this->assertNotEmpty($response->json('staff_code'));

        $createdUser = User::query()->where('email', 'generated.staff@example.com')->first();

        $this->assertNotNull($createdUser);
        $this->assertTrue(Hash::check($temporaryPassword, $createdUser?->password ?? ''));
    }

    public function test_admin_can_create_branches_and_shifts_without_client_generated_ids(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'status' => 'Active',
        ]);
        $session = $admin->createToken('desktop');

        $branchResponse = $this->withToken($session->plainTextToken)
            ->postJson('/api/branches', [
                'id' => '',
                'branch_name' => 'Sohar Hub',
                'latitude' => 24.3412,
                'longitude' => 56.7292,
                'allowed_radius' => 120,
                'status' => 'Active',
                'address' => 'Sohar, Oman',
                'wifi_ssid' => 'ParcelExpress-Sohar',
            ])
            ->assertCreated();

        $shiftResponse = $this->withToken($session->plainTextToken)
            ->postJson('/api/shifts', [
                'id' => '',
                'shift_name' => 'Night Shift',
                'start_time' => '22:00',
                'end_time' => '06:00',
                'standard_hours' => 8,
                'grace_minutes' => 10,
                'status' => 'Active',
            ])
            ->assertCreated();

        $uuidPattern = '/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i';

        $this->assertMatchesRegularExpression($uuidPattern, $branchResponse->json('id'));
        $this->assertMatchesRegularExpression($uuidPattern, $shiftResponse->json('id'));
    }

    private function seedBranchAndShift(
        string $branchId = 'branch-1',
        string $shiftId = 'shift-1',
    ): array {
        $branch = Branch::query()->create([
            'id' => $branchId,
            'branch_name' => 'Muscat HQ',
            'latitude' => 23.588,
            'longitude' => 58.3829,
            'allowed_radius' => 100,
            'status' => 'Active',
            'address' => 'Muscat, Oman',
            'wifi_ssid' => 'Office-WiFi',
        ]);
        $shift = Shift::query()->create([
            'id' => $shiftId,
            'shift_name' => 'Morning Shift',
            'start_time' => '08:00',
            'end_time' => '17:00',
            'standard_hours' => 8,
            'grace_minutes' => 15,
            'status' => 'Active',
        ]);

        return [$branch, $shift];
    }
}
