<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ApiResponse;
use App\Http\Controllers\Controller;
use App\Models\Leave;
use Illuminate\Http\Request;

class LeaveController extends Controller
{
    public function index()
    {
        $leaves = Leave::where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->get();

        return ApiResponse::respond($leaves, 'Leaves retrieved successfully');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'reason'     => 'required|string',
            'start_date' => 'required|date',
            'end_date'   => 'required|date|after_or_equal:start_date',
        ]);

        $leave = Leave::create([
            'user_id'    => auth()->id(),
            'reason'     => $validated['reason'],
            'start_date' => $validated['start_date'],
            'end_date'   => $validated['end_date'],
            'status'     => 'pending',
        ]);

        return ApiResponse::respond($leave, 'Leave created successfully');
    }

    public function show(Leave $leaf)
    {
        if ((int) $leaf->user_id !== (int) auth()->id()) {
            return ApiResponse::respond(null, 'Unauthorized', 403);
        }

        return ApiResponse::respond($leaf, 'Leave retrieved successfully');
    }

    public function update(Request $request, Leave $leaf)
    {
        if ((int) $leaf->user_id !== (int) auth()->id()) {
            return ApiResponse::respond(null, 'Unauthorized', 403);
        }

        $validated = $request->validate([
            'reason'     => 'sometimes|required|string',
            'start_date' => 'sometimes|required|date',
            'end_date'   => 'sometimes|required|date|after_or_equal:start_date',
            'status'     => 'sometimes|required|in:pending,approved,rejected',
        ]);

        $leaf->update($validated);

        return ApiResponse::respond($leaf, 'Leave updated successfully');
    }

    public function destroy(Leave $leaf)
    {
        if ((int) $leaf->user_id !== (int) auth()->id()) {
            return ApiResponse::respond(null, 'Unauthorized', 403);
        }

        $leaf->delete();

        return ApiResponse::respond(null, 'Leave deleted successfully');
    }
}
