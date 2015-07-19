Template.addMatch.events
    "submit #new-match-form": (event) ->
        event.preventDefault()
        return false if not isAdmin()

        # Get values
        teamAId = $("#blockATeam").val()
        teamBId = $("#blockBTeam").val()

        # validate
        return false if not teamAId.length or not teamBId.length

        matchId = Matches.insertMatch(
            teamAId: teamAId,
            teamBId: teamBId,
            createdAt: new Date()
        )


        return false if not matchId

        # Clear form
        $("#blockATeam").prop('selectedIndex', 0);
        $("#blockBTeam").prop('selectedIndex', 0);

        # Prevent default form submit
        return false
