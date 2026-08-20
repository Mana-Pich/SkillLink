<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PaymentController extends Controller
{
    /**
     * Display all payments.
     */
    public function index(): JsonResponse
    {
        $payments = Payment::with([
            'booking.user',
            'booking.service',
        ])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Payments retrieved successfully.',
            'data' => $payments,
        ]);
    }

    /**
     * Process a simulated payment for a booking.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'booking_id' => ['required', 'exists:bookings,id'],
            'payment_method' => ['required', 'in:card,khqr,wallet'],
        ]);

        $booking = Booking::with([
            'user',
            'service',
        ])->findOrFail($validated['booking_id']);

        /*
         * Only pending bookings can be paid.
         */
        if ($booking->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Only pending bookings can be paid.',
            ], 422);
        }

        /*
         * Prevent duplicate payments.
         */
        if ($booking->payment) {
            return response()->json([
                'success' => false,
                'message' => 'This booking has already been paid.',
            ], 422);
        }

        /*
         * Generate a unique transaction ID.
         */
        $transactionId = 'SL-' . now()->format('YmdHis') . '-' . strtoupper(
            Str::random(6)
        );

        /*
         * This is a simulated payment.
         * No real money is transferred.
         */
        $payment = Payment::create([
            'booking_id' => $booking->id,
            'amount' => $booking->total_amount,
            'payment_method' => $validated['payment_method'],
            'transaction_id' => $transactionId,
            'status' => 'paid',
        ]);

        /*
         * Confirm the booking after successful payment.
         */
        $booking->update([
            'status' => 'confirmed',
        ]);

        $payment->load([
            'booking.user',
            'booking.service',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Payment successful.',
            'data' => $payment,
        ], 201);
    }

    /**
     * Display a single payment.
     */
    public function show(Payment $payment): JsonResponse
    {
        $payment->load([
            'booking.user',
            'booking.service',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Payment retrieved successfully.',
            'data' => $payment,
        ]);
    }
}