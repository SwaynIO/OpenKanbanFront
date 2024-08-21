<template>
    <div class="flex justify-center items-center min-h-screen bg-gray-100">
        <div class="w-full max-w-md bg-white rounded-lg shadow-md p-8">
            <h2 class="text-2xl font-semibold text-center text-gray-800 mb-6">Register</h2>
            <form @submit.prevent="register">
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-medium mb-2">Username</label>
                    <input v-model="username" type="text"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                        required>
                </div>
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-medium mb-2">Email</label>
                    <input v-model="email" type="email"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                        required>
                </div>
                <div class="mb-6">
                    <label class="block text-gray-700 text-sm font-medium mb-2">Password</label>
                    <input v-model="password" type="password"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                        required>
                </div>
                <div class="flex items-center justify-between">
                    <button type="submit"
                        class="bg-green-600 hover:bg-green-700 text-white font-medium py-2 px-4 rounded focus:outline-none focus:shadow-outline w-full">Register</button>
                </div>
            </form>
        </div>
    </div>
</template>

<script>
export default {
    name: 'RegisterPage',
    data() {
        return {
            username: '',
            email: '',
            password: ''
        };
    },
    methods: {
        async register() {
            try {
                const response = await fetch('http://localhost:3000/api/auth/register', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        username: this.username,
                        email: this.email,
                        password: this.password
                    })
                });

                if (response.ok) {
                    const data = await response.json();
                    localStorage.setItem('token', data.token);
                    window.dispatchEvent(new Event('storage')); // Notifie le changement d'état
                    this.$router.push('/');
                } else {
                    console.error('Registration failed');
                }
            } catch (error) {
                console.error('Error during registration:', error);
            }
        }
    }
}
</script>
