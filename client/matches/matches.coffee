Template.matches.helpers(
    matches: () ->
        Matches.find {}, {sort: {createdAt: -1}}
)

Template.matches.events(
    "submit .new-match-form": (event) ->
        # Get values
        teamAId = $("#blockATeam").val();
        teamBId = $("#blockBTeam").val();

        # validate
        return false if teamAId.length == 0 or teamBId.length == 0 or
            (not $("#wonA").is(":checked") and not $("#wonB").is(":checked"))

        winTeam = $("#wonA").is(":checked")?teamAId : teamBId;

        Matches.insert(
            teamAId: teamAId,
            teamBId: teamBId,
            winTeam: winTeam
        )

        # Clear form
        $("#blockATeam").prop('selectedIndex', 0);
        $("#blockBTeam").prop('selectedIndex', 0);
        $("#wonA").prop('checked', false);
        $("#wonB").prop('checked', false);

        # Prevent default form submit
        return false;
)
