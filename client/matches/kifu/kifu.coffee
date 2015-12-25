Template.kifu.rendered = () ->
    $('#kifuframe').ready () ->
        $("#kifuframe").contents().find("div").html('My html');
