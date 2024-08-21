import Sortable from 'sortablejs';

export default {
    mounted(el, binding) {
        const sortable = new Sortable(el, binding.value || {});
        el._sortable = sortable;
    },
    unmounted(el) {
        el._sortable.destroy();
    },
};
