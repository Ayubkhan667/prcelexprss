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
}
