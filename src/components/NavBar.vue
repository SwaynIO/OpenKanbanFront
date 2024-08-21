<template>
    <nav class="bg-gray-800 p-4">
        <div class="container mx-auto flex justify-between items-center">
            <div>
                <router-link to="/" class="text-white font-bold text-xl">MyApp</router-link>
            </div>
            <div class="flex space-x-4">
                <router-link v-if="!isAuthenticated" to="/login"
                    class="text-white hover:text-gray-300">Login</router-link>
                <router-link v-if="!isAuthenticated" to="/register"
                    class="text-white hover:text-gray-300">Register</router-link>
                <!-- Utilisation d'un bouton pour logout -->
                <button v-if="isAuthenticated" @click="logout" class="text-white hover:text-gray-300">Logout</button>
            </div>
        </div>
    </nav>
</template>

<script>
export default {
    name: 'NavBar',
    data() {
        return {
            isAuthenticated: !!localStorage.getItem('token') // Vérifie si le token est présent dans le localStorage
        };
    },
    methods: {
        logout() {
            localStorage.removeItem('token');
            this.isAuthenticated = false;

            if (this.$router) {
                console.log('Router is available');
                this.$router.push('/login'); // Redirige vers la page de connexion
            } else {
                console.error('Router is not available');
            }
        },
        checkAuthentication() {
            this.isAuthenticated = !!localStorage.getItem('token');
        }
    },
    created() {
        window.addEventListener('storage', this.checkAuthentication);
    },
    unmounted() { // Utilisation de 'unmounted' à la place de 'destroyed'
        window.removeEventListener('storage', this.checkAuthentication);
    }
}
</script>
