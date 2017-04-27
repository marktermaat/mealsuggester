import $ from "jquery";

export var MealForm = {
  init: channel => {
    $(".js-newmealform").submit(event => {
      const data = $(".js-newmealform")
        .serializeArray()
        .reduce((acc, current) => {
          acc[current["name"]] = current["value"];
          return acc;
        }, {});
      channel.sendMessage("new_meal", data);
      console.log("submit ", JSON.stringify(data));
      event.preventDefault();
    });

    const filterElement = $(".js-newmealfield")[0];
    filterElement.oninput = event => {
      const input = event.target.value;
      channel.sendMessage("show_meals", input);
    };
  },

  clearForm: () => {
    $(".js-newmealform")[0].reset();
  },

  showErrors: errors => {
    for (var name in errors) {
      $(".js-newmealform input[name='" + name + "']").css(
        "border-color",
        "red"
      );
    }
  }
};
