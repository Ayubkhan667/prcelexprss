<?php

namespace App\Support;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class AuditLogger
{
    public static function record(Request $request, array $payload): void
    {
        $user = $request->user();

        DB::table('audit_logs')->insert([
            'id' => (string) Str::uuid(),
            'action' => $payload['action'],
            'title' => $payload['title'],
            'description' => $payload['description'] ?? null,
            'actor_id' => $user?->getKey(),
            'actor_name' => $user?->name ?? $user?->email ?? 'System',
            'actor_role' => $user?->role ?? 'system',
            'target_type' => $payload['target_type'] ?? null,
            'target_id' => $payload['target_id'] ?? null,
            'target_name' => $payload['target_name'] ?? null,
            'metadata' => isset($payload['metadata']) ? json_encode($payload['metadata'], JSON_THROW_ON_ERROR) : null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public static function payload(object $row): array
    {
        return [
            'id' => $row->id,
            'action' => $row->action,
            'title' => $row->title,
            'description' => $row->description,
            'actor_id' => $row->actor_id,
            'actor_name' => $row->actor_name,
            'actor_role' => $row->actor_role,
            'target_type' => $row->target_type,
            'target_id' => $row->target_id,
            'target_name' => $row->target_name,
            'metadata' => $row->metadata ? json_decode($row->metadata, true, 512, JSON_THROW_ON_ERROR) : [],
            'created_at' => $row->created_at,
        ];
    }
}
