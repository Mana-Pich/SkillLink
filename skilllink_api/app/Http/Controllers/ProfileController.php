<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    // ============================================================
    // GET PROFILE
    // ============================================================

    public function show($userId)
    {
        $user = User::find($userId);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $this->formatUser($user),
            ],
        ]);
    }

    // ============================================================
    // UPDATE PROFILE IMAGE
    // ============================================================

    public function updateImage(
        Request $request,
        $userId
    ) {
        $user = User::find($userId);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found.',
            ], 404);
        }

        $request->validate([
            'profile_image' => [
                'required',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120',
            ],
        ]);

        // Delete old image first
        if ($user->profile_image) {
            Storage::disk('public')->delete(
                $user->profile_image
            );
        }

        // Store new image
        $path = $request
            ->file('profile_image')
            ->store(
                'profile_images',
                'public'
            );

        $user->profile_image = $path;
        $user->save();

        return response()->json([
            'success' => true,
            'message' =>
                'Profile image updated successfully.',
            'data' => [
                'user' =>
                    $this->formatUser($user),
            ],
        ]);
    }

    // ============================================================
    // DELETE PROFILE IMAGE
    // ============================================================

    public function deleteImage($userId)
    {
        $user = User::find($userId);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found.',
            ], 404);
        }

        if ($user->profile_image) {
            Storage::disk('public')->delete(
                $user->profile_image
            );
        }

        $user->profile_image = null;
        $user->save();

        return response()->json([
            'success' => true,
            'message' =>
                'Profile image removed successfully.',
            'data' => [
                'user' =>
                    $this->formatUser($user),
            ],
        ]);
    }

    // ============================================================
    // FORMAT USER
    // ============================================================

    private function formatUser(User $user)
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'profile_image' =>
                $user->profile_image,
        ];
    }
}