<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class WalletController extends Controller
{
    /**
     * Get a user's SkillLink Wallet.
     */
    public function show(User $user): JsonResponse
    {
        // Create the wallet automatically
        // if the user does not have one.
        if (!$user->wallet) {
            $user->wallet()->create([
                'balance' => 0,
            ]);
        }

        // Refresh the relationship.
        $user->load('wallet');

        return response()->json([
            'success' => true,
            'message' => 'Wallet retrieved successfully.',
            'data' => [
                'wallet' => $user->wallet,
            ],
        ]);
    }
}