<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Service;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class SkillLinkSeeder extends Seeder
{
    /**
     * Seed the application's demo data.
     */
    public function run(): void
    {
        /*
        |--------------------------------------------------------------------------
        | Providers
        |--------------------------------------------------------------------------
        */

        $providers = [
            [
                'name' => 'David Smith',
                'email' => 'david@skilllink.test',
            ],
            [
                'name' => 'Lisa Chen',
                'email' => 'lisa@skilllink.test',
            ],
            [
                'name' => 'Daniel Wilson',
                'email' => 'daniel@skilllink.test',
            ],
        ];

        foreach ($providers as $provider) {
            User::firstOrCreate(
                ['email' => $provider['email']],
                [
                    'name' => $provider['name'],
                    'password' => Hash::make('password123'),
                    'role' => 'provider',
                ]
            );
        }

        /*
        |--------------------------------------------------------------------------
        | Customers
        |--------------------------------------------------------------------------
        */

        $customers = [
            [
                'name' => 'Michael Brown',
                'email' => 'michael@skilllink.test',
            ],
            [
                'name' => 'Sophia Wilson',
                'email' => 'sophia@skilllink.test',
            ],
            [
                'name' => 'Daniel Lee',
                'email' => 'daniel.lee@skilllink.test',
            ],
            [
                'name' => 'Olivia Taylor',
                'email' => 'olivia@skilllink.test',
            ],
        ];

        foreach ($customers as $customer) {
            User::firstOrCreate(
                ['email' => $customer['email']],
                [
                    'name' => $customer['name'],
                    'password' => Hash::make('password123'),
                    'role' => 'user',
                ]
            );
        }

        /*
        |--------------------------------------------------------------------------
        | Categories
        |--------------------------------------------------------------------------
        */

        $categories = [
            'Technology',
            'Design',
            'Education',
            'Photography',
            'Beauty',
            'Home Services',
        ];

        foreach ($categories as $categoryName) {
            Category::firstOrCreate([
                'name' => $categoryName,
            ]);
        }

        /*
        |--------------------------------------------------------------------------
        | Provider IDs
        |--------------------------------------------------------------------------
        */

        $sarah = User::where('email', 'sarah@skilllink.test')->first();
        $david = User::where('email', 'david@skilllink.test')->first();
        $lisa = User::where('email', 'lisa@skilllink.test')->first();
        $daniel = User::where('email', 'daniel@skilllink.test')->first();

        /*
        |--------------------------------------------------------------------------
        | Category IDs
        |--------------------------------------------------------------------------
        */

        $technology = Category::where('name', 'Technology')->first();
        $design = Category::where('name', 'Design')->first();
        $education = Category::where('name', 'Education')->first();
        $photography = Category::where('name', 'Photography')->first();
        $beauty = Category::where('name', 'Beauty')->first();
        $homeServices = Category::where('name', 'Home Services')->first();

        /*
        |--------------------------------------------------------------------------
        | Services
        |--------------------------------------------------------------------------
        */

        $services = [
            [
                'title' => 'Website Design Consultation',
                'description' => 'Get professional advice on designing a modern and user-friendly website for your business or personal project.',
                'price' => 15.00,
                'duration' => 60,
                'rating' => 4.8,
                'category_id' => $technology->id,
                'provider_id' => $sarah->id,
            ],
            [
                'title' => 'Mobile App Development',
                'description' => 'Professional guidance for planning and developing modern mobile applications.',
                'price' => 25.00,
                'duration' => 90,
                'rating' => 4.9,
                'category_id' => $technology->id,
                'provider_id' => $david->id,
            ],
            [
                'title' => 'Logo Design',
                'description' => 'Create a professional and memorable logo for your business or personal brand.',
                'price' => 20.00,
                'duration' => 60,
                'rating' => 4.7,
                'category_id' => $design->id,
                'provider_id' => $lisa->id,
            ],
            [
                'title' => 'English Conversation Tutoring',
                'description' => 'Practice everyday English conversation with an experienced tutor.',
                'price' => 10.00,
                'duration' => 60,
                'rating' => 4.9,
                'category_id' => $education->id,
                'provider_id' => $daniel->id,
            ],
            [
                'title' => 'Portrait Photography',
                'description' => 'Professional portrait photography for personal profiles, social media, and special occasions.',
                'price' => 35.00,
                'duration' => 90,
                'rating' => 4.8,
                'category_id' => $photography->id,
                'provider_id' => $lisa->id,
            ],
            [
                'title' => 'Hair Styling',
                'description' => 'Professional hair styling for everyday looks, events, and special occasions.',
                'price' => 18.00,
                'duration' => 60,
                'rating' => 4.6,
                'category_id' => $beauty->id,
                'provider_id' => $sarah->id,
            ],
            [
                'title' => 'Home Cleaning Service',
                'description' => 'Reliable home cleaning service for apartments and houses.',
                'price' => 30.00,
                'duration' => 120,
                'rating' => 4.7,
                'category_id' => $homeServices->id,
                'provider_id' => $david->id,
            ],
        ];

        foreach ($services as $service) {
            Service::firstOrCreate(
                [
                    'title' => $service['title'],
                    'provider_id' => $service['provider_id'],
                ],
                $service
            );
        }
    }
}