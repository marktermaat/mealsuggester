export var MealFilter = {
    init: (channel) => {
        const filterElement = document.getElementById('mealfilter')
        filterElement.oninput = (event) => {
            const input = event.target.value
            channel.sendMessage("filter_meals", input)
            console.log(event.target.value)
        };
    }
}