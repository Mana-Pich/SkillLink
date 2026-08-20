<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Service;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ServiceController extends Controller
{
    /**
     * Display all services.
     */
    public function index(): JsonResponse
    {
        $services = Service::with([
            'category',
            'provider',
        ])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Services retrieved successfully.',
            'data' => $services,
        ]);
    }

    /**
     * Create a service.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'category_id' => [
                'required',
                'exists:categories,id',
            ],

            'provider_id' => [
                'required',
                'exists:users,id',
            ],

            'title' => [
                'required',
                'string',
                'max:255',
            ],

            'description' => [
                'required',
                'string',
            ],

            'price' => [
                'required',
                'numeric',
                'min:0',
            ],

            'duration' => [
                'required',
                'integer',
                'min:1',
            ],

            'image' => [
                'nullable',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120',
            ],

            'rating' => [
                'nullable',
                'numeric',
                'min:0',
                'max:5',
            ],
        ]);

        /*
        |--------------------------------------------------------------------------
        | Upload Image
        |--------------------------------------------------------------------------
        */

        if ($request->hasFile('image')) {
            $validated['image'] =
                $request->file('image')
                    ->store('services', 'public');
        }

        /*
        |--------------------------------------------------------------------------
        | Create Service
        |--------------------------------------------------------------------------
        */

        $service = Service::create(
            $validated
        );

        $service->load([
            'category',
            'provider',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Service created successfully.',
            'data' => $service,
        ], 201);
    }

    /**
     * Display one service.
     */
    public function show(
        Service $service
    ): JsonResponse {
        $service->load([
            'category',
            'provider',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Service retrieved successfully.',
            'data' => $service,
        ]);
    }

    /**
     * Update a service.
     */
    public function update(
        Request $request,
        Service $service
    ): JsonResponse {
        $validated = $request->validate([
            'category_id' => [
                'required',
                'exists:categories,id',
            ],

            'provider_id' => [
                'required',
                'exists:users,id',
            ],

            'title' => [
                'required',
                'string',
                'max:255',
            ],

            'description' => [
                'required',
                'string',
            ],

            'price' => [
                'required',
                'numeric',
                'min:0',
            ],

            'duration' => [
                'required',
                'integer',
                'min:1',
            ],

            'image' => [
                'nullable',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120',
            ],

            'rating' => [
                'nullable',
                'numeric',
                'min:0',
                'max:5',
            ],
        ]);

        /*
        |--------------------------------------------------------------------------
        | Upload New Image
        |--------------------------------------------------------------------------
        */

        if ($request->hasFile('image')) {
            $validated['image'] =
                $request->file('image')
                    ->store('services', 'public');
        }

        /*
        |--------------------------------------------------------------------------
        | Update Service
        |--------------------------------------------------------------------------
        */

        $service->update(
            $validated
        );

        $service->load([
            'category',
            'provider',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Service updated successfully.',
            'data' => $service,
        ]);
    }

    /**
     * Delete a service.
     */
    public function destroy(
        Service $service
    ): JsonResponse {
        $service->delete();

        return response()->json([
            'success' => true,
            'message' => 'Service deleted successfully.',
        ]);
    }
}