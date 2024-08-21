<template>
    <div class="p-6 bg-gray-100 min-h-screen">
        <!-- Bouton pour ajouter une nouvelle équipe -->
        <div class="mb-6 flex justify-between items-center">
            <h3 class="text-2xl font-bold text-gray-800">Your Kanban Boards</h3>
            <button @click="openNewTeamModal"
                class="bg-blue-500 text-white px-4 py-2 rounded-lg shadow-md hover:bg-blue-600">
                + New Team
            </button>
        </div>

        <!-- Sélection d'une équipe -->
        <div v-if="teams.length > 0" class="mb-6">
            <h4 class="text-lg font-semibold text-gray-700 mb-3">Select a Team</h4>
            <div class="flex space-x-4 overflow-x-auto">
                <div v-for="team in teams" :key="team.id"
                    class="bg-white p-4 rounded-lg shadow hover:shadow-lg transition-shadow cursor-pointer"
                    @click="selectTeam(team.id)">
                    <h5 class="text-lg font-bold text-gray-800">{{ team.name }}</h5>
                </div>
            </div>
        </div>
        <div v-else>
            <p class="text-gray-600">You have no teams. Create a new team to start organizing your tasks.</p>
        </div>

        <!-- Affichage des tableaux pour l'équipe sélectionnée -->
        <div v-if="selectedTeamId" class="mb-6">
            <div class="flex justify-between items-center mb-4">
                <h4 class="text-lg font-semibold text-gray-700">Boards in {{ getSelectedTeamName() }}</h4>
                <button @click="openNewBoardModal"
                    class="bg-blue-500 text-white px-4 py-2 rounded-lg shadow-md hover:bg-blue-600">
                    + New Board
                </button>
            </div>
            <div v-if="boards.length > 0" class="flex space-x-4 overflow-x-auto">
                <div v-for="board in boards" :key="board.id"
                    class="bg-white p-4 rounded-lg shadow hover:shadow-lg transition-shadow cursor-pointer"
                    @click="selectBoard(board.id)">
                    <h5 class="text-lg font-bold text-gray-800">{{ board.name }}</h5>
                </div>
            </div>
            <div v-else>
                <p class="text-gray-600">You have no boards in this team. Create a new board to start organizing your
                    tasks.</p>
            </div>
        </div>

        <!-- Section des listes pour le tableau sélectionné -->
        <div v-if="selectedBoardId" class="mt-6">
            <h4 class="text-xl font-bold text-gray-700 mb-4">Lists in {{ getSelectedBoardName() }}</h4>
            <div v-sortable="{ group: 'tasks', onEnd: onTaskDrop }" class="flex space-x-4 overflow-x-auto pb-6">
                <div v-for="list in lists" :key="list.id" class="bg-gray-100 rounded-lg shadow p-4 w-64">
                    <h4 class="text-lg font-semibold mb-2 text-gray-800">{{ list.name }}</h4>
                    <div class="space-y-2">
                        <div v-for="task in list.tasks" :key="task.id"
                            class="bg-white rounded p-3 shadow hover:bg-gray-100 cursor-pointer" :data-id="task.id"
                            @click="openTaskDetails(task.id)">
                            <p class="text-gray-800">{{ task.name }}</p>
                        </div>

                    </div>
                    <button @click="openNewTaskModal(list.id)" class="mt-2 text-blue-500 hover:text-blue-600">+ Add a
                        task</button>
                </div>
                <div class="bg-gray-200 rounded-lg shadow p-4 w-64 flex items-center justify-center">
                    <button @click="openNewListModal" class="text-blue-500 hover:text-blue-600">+ Add a list</button>
                </div>
            </div>
        </div>

        <!-- Modale pour créer une nouvelle équipe -->
        <div v-if="showTeamModal" class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
            <div class="bg-white p-6 rounded shadow-lg w-full max-w-md">
                <h3 class="text-lg font-semibold mb-4 text-gray-800">Create New Team</h3>
                <input v-model="newTeamName" placeholder="Team Name" class="border rounded p-2 w-full mb-4">
                <div class="flex justify-end">
                    <button @click="closeTeamModal" class="text-gray-600 mr-4">Cancel</button>
                    <button @click="createTeam"
                        class="bg-green-600 text-white px-4 py-2 rounded shadow-md hover:bg-green-700">Create
                        Team</button>
                </div>
            </div>
        </div>

        <!-- Modale pour créer un nouveau tableau -->
        <div v-if="showBoardModal" class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
            <div class="bg-white p-6 rounded shadow-lg w-full max-w-md">
                <h3 class="text-lg font-semibold mb-4 text-gray-800">Create New Board</h3>
                <input v-model="newBoardName" placeholder="Board Name" class="border rounded p-2 w-full mb-4">
                <div class="flex justify-end">
                    <button @click="closeBoardModal" class="text-gray-600 mr-4">Cancel</button>
                    <button @click="createBoard"
                        class="bg-green-600 text-white px-4 py-2 rounded shadow-md hover:bg-green-700">Create
                        Board</button>
                </div>
            </div>
        </div>

        <!-- Modale pour créer une nouvelle tâche -->
        <div v-if="showTaskModal" class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
            <div class="bg-white p-6 rounded shadow-lg w-full max-w-md">
                <h3 class="text-lg font-semibold mb-4 text-gray-800">Create New Task</h3>
                <input v-model="newTaskName" placeholder="Task Name" class="border rounded p-2 w-full mb-4">
                <div class="flex justify-end">
                    <button @click="closeTaskModal" class="text-gray-600 mr-4">Cancel</button>
                    <button @click="createTask"
                        class="bg-green-600 text-white px-4 py-2 rounded shadow-md hover:bg-green-700">Create
                        Task</button>
                </div>
            </div>
        </div>

        <!-- Modale pour les détails de la tâche -->
        <div v-if="showTaskDetailsModal"
            class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
            <div class="bg-white p-6 rounded shadow-lg w-full max-w-lg">
                <h3 class="text-lg font-semibold mb-4 text-gray-800">{{ taskDetails.name }}</h3>
                <p class="text-gray-600 mb-4">{{ taskDetails.description }}</p>
                <div class="mb-4">
                    <label class="block text-gray-700 font-semibold">Assign to:</label>
                    <select v-model="taskDetails.assignedTo" class="border rounded p-2 w-full">
                        <option v-for="user in users" :key="user.id" :value="user.id">{{ user.username }}</option>
                    </select>
                </div>
                <div>
                    <h4 class="text-lg font-semibold text-gray-800">Comments</h4>
                    <ul class="mb-4">
                        <li v-for="comment in taskComments" :key="comment.id" class="border-b py-2">
                            <strong>{{ comment.username }}:</strong> {{ comment.content }}
                        </li>
                    </ul>
                    <textarea v-model="newComment" placeholder="Add a comment..."
                        class="border rounded p-2 w-full mb-2"></textarea>
                    <button @click="addComment"
                        class="bg-blue-500 text-white px-4 py-2 rounded shadow-md hover:bg-blue-600">Add
                        Comment</button>
                </div>
                <div class="flex justify-end mt-4">
                    <button @click="closeTaskDetailsModal" class="text-gray-600 mr-4">Close</button>
                </div>
            </div>
        </div>

        <!-- Modale pour créer une nouvelle liste -->
        <div v-if="showListModal" class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
            <div class="bg-white p-6 rounded shadow-lg w-full max-w-md">
                <h3 class="text-lg font-semibold mb-4 text-gray-800">Create New List</h3>
                <input v-model="newListName" placeholder="List Name" class="border rounded p-2 w-full mb-4">
                <div class="flex justify-end">
                    <button @click="closeListModal" class="text-gray-600 mr-4">Cancel</button>
                    <button @click="createList"
                        class="bg-green-600 text-white px-4 py-2 rounded shadow-md hover:bg-green-700">Create
                        List</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import SortableDirective from './directives/sortable.js';

export default {
    name: 'HomePage',
    directives: {
        sortable: SortableDirective,
    },
    data() {
        return {
            teams: [],
            boards: [],
            selectedTeamId: null,
            selectedBoardId: null,
            lists: [],
            showTaskModal: false,
            showListModal: false,
            showBoardModal: false,
            showTeamModal: false,
            showTaskDetailsModal: false,
            newTaskName: '',
            newListName: '',
            newBoardName: '',
            newTeamName: '',
            currentListId: null,
            taskDetails: {},
            taskComments: [],
            newComment: '',
            users: [], // Liste des utilisateurs de l'équipe
        };
    },
    created() {
        this.fetchTeams();
    },
    methods: {
        async onTaskDrop(evt) {
            const { item, newIndex } = evt;

            console.log('Dropped item:', item); // Inspectez l'élément
            console.log('New index:', newIndex); // Inspectez la nouvelle position

            // Testons l'attribut data-id directement
            const taskId = item.getAttribute('data-id');
            console.log('Task ID:', taskId); // Vérifiez cette valeur dans la console
            if (!taskId) {
                console.error('Task ID is null');
                return;
            }

            const position = newIndex + 1;

            try {
                const response = await fetch('http://localhost:3000/api/tasks/position', {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${localStorage.getItem('token')}`,
                    },
                    body: JSON.stringify({
                        taskId: taskId,
                        position: position,
                    }),
                });

                if (!response.ok) {
                    throw new Error('Failed to update task position');
                }

                this.fetchListsAndTasks(this.selectedBoardId);
            } catch (error) {
                console.error('Error updating task position:', error);
            }
        },

        async openTaskDetails(taskId) {
            try {
                const response = await fetch(`http://localhost:3000/api/tasks/${taskId}`, {
                    method: 'GET',
                    headers: {
                        'Authorization': `Bearer ${localStorage.getItem('token')}`
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    this.taskDetails = data.task;
                    this.taskComments = data.comments;
                    this.showTaskDetailsModal = true;
                } else {
                    console.error('Failed to fetch task details');
                }
            } catch (error) {
                console.error('Error fetching task details:', error);
            }
        },

        async addComment() {
            if (!this.newComment) return;

            try {
                const response = await fetch('http://localhost:3000/api/comments', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${localStorage.getItem('token')}`
                    },
                    body: JSON.stringify({
                        taskId: this.taskDetails.id,
                        content: this.newComment
                    })
                });

                if (response.ok) {
                    this.newComment = '';
                    this.openTaskDetails(this.taskDetails.id); // Refresh comments
                } else {
                    console.error('Failed to add comment');
                }
            } catch (error) {
                console.error('Error adding comment:', error);
            }
        },

        closeTaskDetailsModal() {
            this.showTaskDetailsModal = false;
        },

        async fetchTeams() {
            try {
                const response = await fetch('http://localhost:3000/api/teams', {
                    method: 'GET',
                    headers: {
                        'Authorization': `Bearer ${localStorage.getItem('token')}`
                    }
                });

                if (response.ok) {
                    this.teams = await response.json();
                } else {
                    console.error('Failed to fetch teams');
                }
            } catch (error) {
                console.error('Error fetching teams:', error);
            }
        },
        async fetchBoards() {
            try {
                const response = await fetch(`http://localhost:3000/api/boards/team/${this.selectedTeamId}`, {
                    method: 'GET',
                    headers: {
                        'Authorization': `Bearer ${localStorage.getItem('token')}`
                    }
                });

                if (response.ok) {
                    this.boards = await response.json();
                } else {
                    console.error('Failed to fetch boards');
                }
            } catch (error) {
                console.error('Error fetching boards:', error);
            }
        },
        getSelectedTeamName() {
            const team = this.teams.find(team => team.id === this.selectedTeamId);
            return team ? team.name : '';
        },
        getSelectedBoardName() {
            const board = this.boards.find(board => board.id === this.selectedBoardId);
            return board ? board.name : '';
        },
        openNewTeamModal() {
            this.newTeamName = '';
            this.showTeamModal = true;
        },
        closeTeamModal() {
            this.showTeamModal = false;
        },
        async createTeam() {
            if (!this.newTeamName) return;

            try {
                const response = await fetch('http://localhost:3000/api/teams', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${localStorage.getItem('token')}`
                    },
                    body: JSON.stringify({
                        name: this.newTeamName
                    })
                });

                if (response.ok) {
                    this.fetchTeams(); // Rafraîchir les équipes après la création
                    this.closeTeamModal();
                } else {
                    console.error('Failed to create team');
                }
            } catch (error) {
                console.error('Error creating team:', error);
            }
        },
        selectTeam(teamId) {
            this.selectedTeamId = teamId;
            this.fetchBoards(); // Charger les tableaux pour l'équipe sélectionnée
        },
        openNewBoardModal() {
            this.newBoardName = '';
            this.showBoardModal = true;
        },
        closeBoardModal() {
            this.showBoardModal = false;
        },
        async createBoard() {
            if (!this.newBoardName || !this.selectedTeamId) return;

            try {
                const response = await fetch('http://localhost:3000/api/boards', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${localStorage.getItem('token')}`
                    },
                    body: JSON.stringify({
                        name: this.newBoardName,
                        teamId: this.selectedTeamId
                    })
                });

                if (response.ok) {
                    this.fetchBoards(); // Rafraîchir les tableaux après la création
                    this.closeBoardModal();
                } else {
                    console.error('Failed to create board');
                }
            } catch (error) {
                console.error('Error creating board:', error);
            }
        },
        selectBoard(boardId) {
            this.selectedBoardId = boardId;
            this.fetchListsAndTasks(boardId); // Charger les listes du tableau sélectionné
        },
        async fetchListsAndTasks(boardId) {
            try {
                const response = await fetch(`http://localhost:3000/api/lists/board/${boardId}`, {
                    method: 'GET',
                    headers: {
                        'Authorization': `Bearer ${localStorage.getItem('token')}`
                    }
                });

                if (response.ok) {
                    const lists = await response.json();
                    this.lists = lists.map(list => ({
                        ...list,
                        tasks: Array.isArray(list.tasks) ? list.tasks : [] // S'assurer que tasks est un tableau
                    }));
                    await this.fetchTasksForLists(); // Notez l'utilisation d'await ici pour s'assurer que les tâches sont bien récupérées avant de continuer
                } else {
                    console.error('Failed to fetch lists');
                }
            } catch (error) {
                console.error('Error fetching lists:', error);
            }
        },
        async fetchTasksForLists() {
            try {
                for (let list of this.lists) {
                    const response = await fetch(`http://localhost:3000/api/tasks/list/${list.id}`, {
                        method: 'GET',
                        headers: {
                            'Authorization': `Bearer ${localStorage.getItem('token')}`
                        }
                    });

                    if (response.ok) {
                        list.tasks = await response.json();
                    } else {
                        console.error(`Failed to fetch tasks for list ${list.id}`);
                    }
                }
            } catch (error) {
                console.error('Error fetching tasks:', error);
            }
        },
        openNewTaskModal(listId) {
            this.currentListId = listId;
            this.newTaskName = '';
            this.showTaskModal = true;
        },
        closeTaskModal() {
            this.showTaskModal = false;
        },
        async createTask() {
            if (!this.newTaskName || !this.currentListId) return;

            try {
                const response = await fetch('http://localhost:3000/api/tasks', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${localStorage.getItem('token')}`
                    },
                    body: JSON.stringify({
                        name: this.newTaskName,
                        listId: this.currentListId,
                        position: this.lists.find(list => list.id === this.currentListId).tasks.length + 1
                    })
                });

                if (response.ok) {
                    this.fetchListsAndTasks(this.selectedBoardId); // Rafraîchir les tâches après création
                    this.closeTaskModal();
                } else {
                    console.error('Failed to create task');
                }
            } catch (error) {
                console.error('Error creating task:', error);
            }
        },
        openNewListModal() {
            this.newListName = '';
            this.showListModal = true;
        },
        closeListModal() {
            this.showListModal = false;
        },
        async createList() {
            if (!this.newListName || !this.selectedBoardId) return;

            try {
                const response = await fetch('http://localhost:3000/api/lists', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${localStorage.getItem('token')}`
                    },
                    body: JSON.stringify({
                        name: this.newListName,
                        boardId: this.selectedBoardId,
                        position: this.lists.length + 1
                    })
                });

                if (response.ok) {
                    this.fetchListsAndTasks(this.selectedBoardId); // Rafraîchir les listes après création
                    this.closeListModal();
                } else {
                    console.error('Failed to create list');
                }
            } catch (error) {
                console.error('Error creating list:', error);
            }
        }
    }
}
</script>

<style scoped>
.flex {
    display: flex;
    gap: 1rem;
    overflow-x: auto;
}

.w-64 {
    width: 16rem;
}
</style>
