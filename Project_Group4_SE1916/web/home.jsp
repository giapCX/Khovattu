<%-- 
    Document   : Home
    Created on : 26 May 2025, 11:43:34 pm
    Author     : Giap
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Home - Material Management System</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: {
                            50: '#f0f9ff', 100: '#e0f2fe', 200: '#bae6fd', 300: '#7dd3fc',
                            400: '#38bdf8', 500: '#0ea5e9', 600: '#0284c7', 700: '#0369a1',
                            800: '#075985', 900: '#0c4a6e'
                        },
                        secondary: {
                            50: '#f5f3ff', 100: '#ede9fe', 200: '#ddd6fe', 300: '#c4b5fd',
                            400: '#a78bfa', 500: '#8b5cf6', 600: '#7c3aed', 700: '#6d28d9',
                            800: '#5b21b6', 900: '#4c1d95'
                        }
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif']
                    }
                }
            }
        }
    </script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

        body {
            font-family: 'Inter', sans-serif;
            background-color: #f8fafc;
        }

        .hero-bg {
            background: linear-gradient(135deg, #1e3a8a, #3b82f6);
        }

        .btn-primary {
            background: linear-gradient(to right, #3b82f6, #6366f1);
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            transform: scale(1.05);
            box-shadow: 0 10px 15px -3px rgba(59, 130, 246, 0.3), 0 4px 6px -2px rgba(59, 130, 246, 0.1);
        }

        .card {
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            border-radius: 1rem;
            border: 1px solid #e5e7eb;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }

        .dark-mode {
            background-color: #1a202c;
            color: #e2e8f0;
        }

        .dark-mode .hero-bg {
            background: linear-gradient(135deg, #111827, #1f2937);
        }

        .dark-mode .card {
            background-color: #2d3748;
            color: #e2e8f0;
            border-color: #4a5568;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .animate-fadeInUp {
            animation: fadeInUp 0.5s ease-out forwards;
        }

        .delay-100 { animation-delay: 0.1s; }
        .delay-200 { animation-delay: 0.2s; }
        .delay-300 { animation-delay: 0.3s; }

        @media (max-width: 768px) {
            .hero-content {
                padding: 2rem;
            }
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
    <!-- Header -->
    <header class="bg-white dark:bg-gray-800 shadow-sm">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
            <div class="flex items-center">
                <div class="w-10 h-10 rounded-full bg-primary-600 flex items-center justify-center mr-3">
                    <i class="fas fa-boxes text-white text-xl"></i>
                </div>
                <h1 class="text-xl font-bold text-gray-800 dark:text-white">Material Management System</h1>
            </div>
            <div class="flex items-center space-x-4">
                <button id="toggleDarkMode" class="bg-gray-200 dark:bg-gray-700 p-2 rounded-full hover:bg-gray-300 dark:hover:bg-gray-600">
                    <i class="fas fa-moon text-gray-700 dark:text-yellow-300 text-lg"></i>
                </button>
                <a href="login.jsp" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center hover:shadow-lg transition-all">
                    <i class="fas fa-sign-in-alt mr-2"></i>
                    Login
                </a>
            </div>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero-bg text-white py-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center hero-content">
            <h2 class="text-4xl md:text-5xl font-bold mb-6 animate-fadeInUp">Welcome to the Material Management System</h2>
            <p class="text-lg md:text-xl mb-8 animate-fadeInUp delay-100">Manage materials efficiently, easily, and intelligently. Log in now to get started!</p>
            <a href="login.jsp" class="btn-primary text-white px-8 py-3 rounded-lg text-lg font-medium inline-flex items-center animate-fadeInUp delay-200">
                <i class="fas fa-sign-in-alt mr-2"></i>
                Login Now
            </a>
        </div>
    </section>

    <!-- Features Section -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <h2 class="text-3xl font-bold text-gray-800 dark:text-white text-center mb-12">Key Features</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div class="card bg-white dark:bg-gray-800 p-6 animate-fadeInUp">
                <div class="flex items-center mb-4">
                    <i class="fas fa-boxes text-primary-600 text-3xl mr-3"></i>
                    <h3 class="text-xl font-semibold text-gray-800 dark:text-white">Material Management</h3>
                </div>
                <p class="text-gray-600 dark:text-gray-300">Track and manage all materials in the warehouse with an intuitive and easy-to-use interface.</p>
            </div>
            <div class="card bg-white dark:bg-gray-800 p-6 animate-fadeInUp delay-100">
                <div class="flex items-center mb-4">
                    <i class="fas fa-clipboard-list text-primary-600 text-3xl mr-3"></i>
                    <h3 class="text-xl font-semibold text-gray-800 dark:text-white">Requests & Approvals</h3>
                </div>
                <p class="text-gray-600 dark:text-gray-300">Create and track material withdrawal, purchase, and repair requests with fast approval processes.</p>
            </div>
            <div class="card bg-white dark:bg-gray-800 p-6 animate-fadeInUp delay-200">
                <div class="flex items-center mb-4">
                    <i class="fas fa-chart-bar text-primary-600 text-3xl mr-3"></i>
                    <h3 class="text-xl font-semibold text-gray-800 dark:text-white">Reports & Statistics</h3>
                </div>
                <p class="text-gray-600 dark:text-gray-300">Analyze material data with detailed charts and reports to support decision-making.</p>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-gray-100 dark:bg-gray-800 text-center p-6 border-t border-gray-200 dark:border-gray-700">
        <p class="text-gray-600 dark:text-gray-300 text-sm">Material Management System - Version 2.0 © 2025 | <a href="mailto:support@company.com" class="text-primary-600 dark:text-primary-400 hover:underline text-base">Contact Support</a></p>
    </footer>

    <!-- JavaScript -->
    <script>
        // Dark Mode Toggle
        const toggleDarkMode = document.getElementById('toggleDarkMode');
        toggleDarkMode.addEventListener('click', () => {
            document.body.classList.toggle('dark-mode');
            const icon = toggleDarkMode.querySelector('i');
            icon.classList.toggle('fa-moon');
            icon.classList.toggle('fa-sun');
            localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
        });

        // Load Dark Mode Preference
        if (localStorage.getItem('darkMode') === 'true') {
            document.body.classList.add('dark-mode');
            toggleDarkMode.querySelector('i').classList.replace('fa-moon', 'fa-sun');
        }
    </script>
</body>
</html>
