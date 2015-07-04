Template.matches.helpers({
    matches: function() {
        return Matches.find({}, {sort: {createdAt: -1}});
    },
});

Template.matches.events({
    "submit .new-match-form": function (event) {
        // Get values
        var teamAId = $("#blockATeam").val();
        var teamBId = $("#blockBTeam").val();
        if (teamAId.length == 0 || teamBId.length == 0) {
            return false;
        }

        var winTeam = $("#wonA").is(":checked")?teamAId : teamBId;

        Matches.insert({
            teamAId: teamAId,
            teamBId: teamBId,
            winTeam: winTeam
        });

        // Clear form
        $("#blockATeam").prop('selectedIndex', 0);
        $("#blockBTeam").prop('selectedIndex', 0);
        $("#wonA").prop('checked', false);
        $("#wonB").prop('checked', false);

        // Prevent default form submit
        return false;
    }
});
