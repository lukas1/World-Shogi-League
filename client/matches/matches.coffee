Template.matches.helpers(
    matches: () ->
        Matches.find {}, {sort: {createdAt: -1}}
)

Template.matches.events(
    "submit #new-match-form": (event) ->
        return false if not Meteor.userId()?

        # Get values
        teamAId = $("#blockATeam").val();
        teamBId = $("#blockBTeam").val();

        # validate
        return false if teamAId.length == 0 or teamBId.length == 0 or
            (not $("#wonA").is(":checked") and not $("#wonB").is(":checked"))

        winTeam = if $("#wonA").is(":checked") then teamAId else teamBId
        defaultWin = $("#defaultWin").is(":checked")

        return false if not Matches.insertMatch(
            teamAId: teamAId,
            teamBId: teamBId,
            winTeam: winTeam
            defaultWin: defaultWin
        )

        # Clear form
        $("#blockATeam").prop('selectedIndex', 0);
        $("#blockBTeam").prop('selectedIndex', 0);
        $("#wonA").prop('checked', false);
        $("#wonB").prop('checked', false);
        $("#defaultWin").prop('checked', false);

        # Prevent default form submit
        return false;
)
