<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $seedPath = base_path('../tool/mock_seed.json');
        if (! File::exists($seedPath)) {
            return;
        }

        $seed = json_decode(File::get($seedPath), true, 512, JSON_THROW_ON_ERROR);
        $password = Hash::make($seed['meta']['default_password'] ?? 'password123');

        DB::transaction(function () use ($seed, $password) {
            $legacyUserMap = [];
            $scopeBranchMap = [
                'u002' => 'b001',
            ];
            $scopeDepartmentMap = [
                'u002' => 'Logistics',
            ];
            $branchWifiMap = [
                'b001' => 'PE-MUSCAT-HQ',
                'b002' => 'PE-SALALAH',
                'b003' => 'PE-SOHAR',
                'b004' => 'PE-NIZWA',
            ];
            $now = now()->toIso8601String();

            foreach ($seed['users'] as $index => $user) {
                $newUserId = $index + 1;
                $legacyUserMap[$user['id']] = $newUserId;

                DB::table('users')->insert([
                    'id' => $newUserId,
                    'legacy_id' => $user['id'],
                    'name' => $user['name'],
                    'email' => $user['email'],
                    'mobile' => $user['mobile'],
                    'role' => $user['role'],
                    'scope_branch_id' => $scopeBranchMap[$user['id']] ?? null,
                    'scope_department' => $scopeDepartmentMap[$user['id']] ?? null,
                    'status' => $user['status'],
                    'device_id' => $user['device_id'],
                    'profile_image_url' => $user['profile_image_url'],
                    'password' => $password,
                    'created_at' => $user['created_at'] ?? $now,
                    'updated_at' => $user['created_at'] ?? $now,
                ]);
            }

            $this->insertBranches($seed['branches'], $branchWifiMap, $now);
            $this->insertSimple('shifts', $seed['shifts'], $now);
            $this->insertStaff($seed['staff'], $legacyUserMap, $now);
            $this->insertSimple('attendance', $seed['attendance'], $now);
            $this->insertSimple('salaries', $seed['salaries'], $now);
            $this->insertSimple('loans', $seed['loans'], $now);
            $this->insertSimple('leaves', $seed['leaves'], $now);
            $this->insertExpenses($seed['expenses'], $now);
            $this->insertSimple('tasks', $seed['tasks'], $now);
            $this->insertSimple('kpis', $seed['kpis'], $now);
            $this->insertSimple('attendance_edit_logs', $seed['edit_logs'], $now);
            $this->insertSimple('notifications', $seed['notifications'], $now);
            $this->insertSimple('holidays', $seed['holidays'], $now);
            $this->insertRosterSamples($now);
            $this->insertHelpdeskSamples($now);
            $this->insertAnnouncementSamples($now);
        });
    }

    private function insertSimple(string $table, array $rows, string $fallbackTimestamp): void
    {
        foreach ($rows as $row) {
            $createdAt = $row['created_at'] ?? $fallbackTimestamp;
            DB::table($table)->insert([
                ...$row,
                'created_at' => $createdAt,
                'updated_at' => $row['updated_at'] ?? $createdAt,
            ]);
        }
    }

    private function insertBranches(array $rows, array $branchWifiMap, string $fallbackTimestamp): void
    {
        foreach ($rows as $row) {
            $createdAt = $row['created_at'] ?? $fallbackTimestamp;
            DB::table('branches')->insert([
                ...$row,
                'wifi_ssid' => $row['wifi_ssid'] ?? ($branchWifiMap[$row['id']] ?? null),
                'created_at' => $createdAt,
                'updated_at' => $row['updated_at'] ?? $createdAt,
            ]);
        }
    }

    private function insertStaff(array $rows, array $legacyUserMap, string $fallbackTimestamp): void
    {
        foreach ($rows as $row) {
            $createdAt = $row['created_at'] ?? $fallbackTimestamp;
            DB::table('staff')->insert([
                ...$row,
                'user_id' => isset($legacyUserMap[$row['user_id']]) ? $legacyUserMap[$row['user_id']] : null,
                'skills' => isset($row['skills']) ? json_encode($row['skills'], JSON_THROW_ON_ERROR) : null,
                'social_media' => isset($row['social_media']) ? json_encode($row['social_media'], JSON_THROW_ON_ERROR) : null,
                'hobbies' => isset($row['hobbies']) ? json_encode($row['hobbies'], JSON_THROW_ON_ERROR) : null,
                'created_at' => $createdAt,
                'updated_at' => $row['updated_at'] ?? $createdAt,
            ]);
        }
    }

    private function insertExpenses(array $rows, string $fallbackTimestamp): void
    {
        foreach ($rows as $row) {
            $createdAt = $row['created_at'] ?? $fallbackTimestamp;
            DB::table('expenses')->insert([
                ...$row,
                'receipt_images' => json_encode($row['receipt_images'] ?? [], JSON_THROW_ON_ERROR),
                'created_at' => $createdAt,
                'updated_at' => $row['updated_at'] ?? $createdAt,
            ]);
        }
    }

    private function insertRosterSamples(string $fallbackTimestamp): void
    {
        $samples = [
            [
                'id' => 'roster_demo_001',
                'staff_id' => 'st001',
                'staff_name' => 'Salma Al-Rashdi',
                'staff_code' => 'SHR-001',
                'roster_date' => '2026-05-28',
                'shift_id' => 's001',
                'shift_name' => 'Morning Shift',
                'start_time' => '08:00',
                'end_time' => '16:00',
                'status' => 'Scheduled',
                'notes' => 'Primary delivery route',
                'assigned_by' => 'Saif Al-Bulushi',
            ],
            [
                'id' => 'roster_demo_002',
                'staff_id' => 'st002',
                'staff_name' => 'Khalid Al-Balushi',
                'staff_code' => 'SHR-002',
                'roster_date' => '2026-05-28',
                'shift_id' => 's002',
                'shift_name' => 'Day Shift',
                'start_time' => '09:00',
                'end_time' => '17:00',
                'status' => 'Scheduled',
                'notes' => 'Warehouse coverage',
                'assigned_by' => 'Saif Al-Bulushi',
            ],
        ];

        foreach ($samples as $row) {
            DB::table('shift_rosters')->updateOrInsert(
                ['id' => $row['id']],
                [
                    ...$row,
                    'created_at' => $fallbackTimestamp,
                    'updated_at' => $fallbackTimestamp,
                ],
            );
        }

        DB::table('shift_swap_requests')->updateOrInsert(
            ['id' => 'swap_demo_001'],
            [
                'requester_staff_id' => 'st001',
                'requester_name' => 'Salma Al-Rashdi',
                'requester_code' => 'SHR-001',
                'target_staff_id' => 'st002',
                'target_name' => 'Khalid Al-Balushi',
                'target_code' => 'SHR-002',
                'roster_date' => '2026-05-28',
                'requester_shift_id' => 's001',
                'requester_shift_name' => 'Morning Shift',
                'target_shift_id' => 's002',
                'target_shift_name' => 'Day Shift',
                'reason' => 'Personal appointment in the morning.',
                'status' => 'Pending',
                'approved_by' => null,
                'approved_at' => null,
                'rejection_reason' => null,
                'created_at' => $fallbackTimestamp,
                'updated_at' => $fallbackTimestamp,
            ],
        );
    }

    private function insertHelpdeskSamples(string $fallbackTimestamp): void
    {
        DB::table('helpdesk_tickets')->updateOrInsert(
            ['id' => 'helpdesk_demo_001'],
            [
                'staff_id' => 'st001',
                'staff_name' => 'Salma Al-Rashdi',
                'staff_code' => 'SHR-001',
                'subject' => 'Attendance selfie upload issue',
                'category' => 'Attendance',
                'message' => 'Check-out selfie failed on weak connection and the queue retried twice.',
                'status' => 'In Progress',
                'response' => 'We are reviewing the sync logs and device network state.',
                'responded_by' => 'Saif Al-Bulushi',
                'responded_at' => $fallbackTimestamp,
                'created_at' => $fallbackTimestamp,
                'updated_at' => $fallbackTimestamp,
            ],
        );
    }

    private function insertAnnouncementSamples(string $fallbackTimestamp): void
    {
        DB::table('notifications')->updateOrInsert(
            ['id' => 'announcement_demo_001'],
            [
                'title' => 'Weekly operations briefing',
                'body' => 'Friday shift handover will start 30 minutes earlier this week.',
                'type' => 'announcement',
                'staff_id' => null,
                'staff_name' => null,
                'is_read' => false,
                'target_role' => 'all',
                'created_at' => $fallbackTimestamp,
                'updated_at' => $fallbackTimestamp,
            ],
        );
    }
}
