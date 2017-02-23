import $ from "jquery"

export var Meals = {
    init: (channel) => {
        $('.js-meals').on("click", ".js-meal", (event) => {
            const mealname = $(event.currentTarget).children(".js-mealname").text()
            $(".js-newmealform input[name='name']").val(mealname)
        })
    }
}