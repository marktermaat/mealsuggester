import $ from "jquery";

export var Meals = {
  init: channel => {
    $(".js-meals").on("click", ".js-meal", event => {
      console.log("1");
      // Select clicked meal
      if ($(event.currentTarget).hasClass("selected-meal")) {
        $(".selected-meal").removeClass("selected-meal");
      } else {
        $(".selected-meal").removeClass("selected-meal");
        $(event.currentTarget).addClass("selected-meal");

        // Insert meal in new meal form
        const mealname = $(event.currentTarget).children(".js-mealname").text();
        $(".js-newmealform input[name='name']").val(mealname);
      }
    });

    // Remove the selection when the user clicks somewhere else
    $(document).on("click", function(event) {
      if (!$(event.target).closest(".js-meals").length) {
        $(".selected-meal").removeClass("selected-meal");
      }
    });

    $(".js-meals").on("click", ".js-mealsnooze", event => {
      console.log("2");
      console.log($(event.target));
      console.log($(event.target).parents(".js-meal"));
      const id = $(event.target).parents(".js-meal").data("id");
      channel.sendMessage("snooze_meal", { id: id });
    });
  }
};
