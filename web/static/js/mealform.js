import $ from "jquery"

export var MealForm = {
    init: (channel) => {
        $('#newmealform').submit((event) => {
            const data = $('#newmealform').serializeArray().reduce( (acc, current) => {
                acc[current['name']] = current['value']
                return acc
            }, {})
            channel.sendMessage("new_meal", data)
            console.log("submit ", JSON.stringify(data))
            event.preventDefault();
        });
    }
}