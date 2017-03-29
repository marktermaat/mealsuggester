import $ from "jquery"

export var Meals = {
    init: (channel) => {
        $('.js-meals').on('click', '.js-meal', (event) => {
            // Select clicked meal
            $(".selected-meal").removeClass("selected-meal")
            $(event.currentTarget).addClass("selected-meal")

            // Insert meal in new meal form
            const mealname = $(event.currentTarget).children(".js-mealname").text()
            $(".js-newmealform input[name='name']").val(mealname)
        });

        // Remove the selection when the user clicks somewhere else
        $(document).on('click', function (event) {
            if (!$(event.target).closest('.js-meals').length) {
                $(".selected-meal").removeClass("selected-meal")
            }
        });

        $('.js-meals').on('click', '.js-mealsnooze', (event) => {
            const id = $(event.target).parent('.js-meal').data('id')
            channel.sendMessage('snooze_meal', { id: id })
        });
    },
}