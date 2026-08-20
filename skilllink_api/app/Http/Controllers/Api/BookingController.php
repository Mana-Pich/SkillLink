<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    /**
     * Display a listing of bookings.
     */
    public function index(Request $request)
    {
        $query = Booking::with([
            'user',
            'service.category',
            'service.provider',
            'payment',
        ]);

        // Customer bookings
        if ($request->filled('user_id')) {
            $query->where(
                'user_id',
                $request->user_id
            );
        }

        // Provider bookings
        if ($request->filled('provider_id')) {
            $query->whereHas(
                'service',
                function ($serviceQuery) use ($request) {
                    $serviceQuery->where(
                        'provider_id',
                        $request->provider_id
                    );
                }
            );
        }

        $bookings = $query
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Bookings retrieved successfully.',
            'data' => $bookings,
        ]);
    }

    /**
     * Store a newly created booking.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => [
                'required',
                'exists:users,id',
            ],

            'service_id' => [
                'required',
                'exists:services,id',
            ],

            'booking_date' => [
                'required',
                'date',
            ],

            'booking_time' => [
                'required',
                'date_format:H:i',
            ],

            'total_amount' => [
                'required',
                'numeric',
                'min:0',
            ],
        ]);

        $booking = Booking::create([
            'user_id' => $validated['user_id'],
            'service_id' => $validated['service_id'],
            'booking_date' =>
                $validated['booking_date'],
            'booking_time' =>
                $validated['booking_time'],
            'total_amount' =>
                $validated['total_amount'],
            'status' => 'pending',
        ]);

        $booking->load([
            'user',
            'service.category',
            'service.provider',
            'payment',
        ]);

        return response()->json([
            'success' => true,
            'message' =>
                'Booking created successfully.',
            'data' => $booking,
        ], 201);
    }

    /**
     * Display the specified booking.
     */
    public function show(Booking $booking)
    {
        $booking->load([
            'user',
            'service.category',
            'service.provider',
            'payment',
        ]);

        return response()->json([
            'success' => true,
            'message' =>
                'Booking retrieved successfully.',
            'data' => $booking,
        ]);
    }

    /**
     * Update the specified booking.
     */
    public function update(
        Request $request,
        Booking $booking
    ) {
        $validated = $request->validate([
            'status' => [
                'sometimes',
                'in:pending,confirmed,completed,cancelled',
            ],

            'booking_date' => [
                'sometimes',
                'date',
            ],

            'booking_time' => [
                'sometimes',
                'date_format:H:i',
            ],

            'total_amount' => [
                'sometimes',
                'numeric',
                'min:0',
            ],
        ]);

        $booking->update($validated);

        $booking->load([
            'user',
            'service.category',
            'service.provider',
            'payment',
        ]);

        return response()->json([
            'success' => true,
            'message' =>
                'Booking updated successfully.',
            'data' => $booking,
        ]);
    }

    /**
     * Remove the specified booking.
     */
    public function destroy(
        Booking $booking
    ) {
        $booking->delete();

        return response()->json([
            'success' => true,
            'message' =>
                'Booking deleted successfully.',
        ]);
    }
}