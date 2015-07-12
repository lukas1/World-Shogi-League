Template.matches.helpers(
    matches: () ->
        Matches.find {}, {sort: {createdAt: -1}}
    rounds: () ->
        rounds = Rounds.find({}, {sort: {createdAt: 1}}).fetch()

        # Display delete button only for the last round
        # Only last round can be removed
        _.extend(_.last(rounds), {"last": true}) if rounds?.length

        return rounds
    isAdmin: () ->
        isAdmin()
    inMiddleOfRound: () ->
        rounds = Rounds.find({}, {sort: {roundNumber: -1}, limit: 1}).fetch()
        if rounds.length
            roundNumber = rounds[0]?.roundNumber
            finished = rounds[0]?.finished
            return finished
        else
            return true
    canAddMatch: () ->
        rounds = Rounds.find({}, {sort: {roundNumber: -1}, limit: 1}).fetch()
        return false if not rounds.length
        roundNumber = rounds[0]?.roundNumber
        finished = rounds[0]?.finished
        return not finished
)

Template.matches.events
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
            createdAt: new Date()
        )

        # Clear form
        $("#blockATeam").prop('selectedIndex', 0);
        $("#blockBTeam").prop('selectedIndex', 0);
        $("#wonA").prop('checked', false);
        $("#wonB").prop('checked', false);
        $("#defaultWin").prop('checked', false);

        # Prevent default form submit
        return false;

    "click #startRound": (event, template) ->
        event.preventDefault()
        return false if not isAdmin()

        rounds = Rounds.find({}, {sort: {roundNumber: -1}, limit: 1}).fetch()
        if rounds.length
            roundNumber = rounds[0]?.roundNumber
            isFinished = rounds[0]?.finished
            return false if not isFinished

        if not roundNumber? or not roundNumber
            roundNumber = 0

        Rounds.insert
            roundNumber: roundNumber + 1
            createdAt: new Date()
            matches: []
            finished: false

        return false

    "click #finishRound": (event, template) ->
        event.preventDefault()
        return false if not isAdmin()

        rounds = Rounds.find({}, {sort: {roundNumber: -1}, limit: 1}).fetch()
        return false if not rounds?.length
        if not rounds[0]?.matches?.length
            alert "Can't finish round. You can't finish a round with no matches"
            return false

        roundId = rounds[0]?._id

        Meteor.call "finishRound", roundId, (error, result) ->
            if error
                alert "Can't finish round. " + error.reason

        return false

    "click .rounddelete": (event, template) ->
        event.preventDefault()
        return false if not isAdmin()

        return false if not confirm "Do you really want to delete this round
        along with all it's matches?"

        roundId = $(event.target).attr('id').replace('round', '')

        Meteor.call "removeRound", roundId, (error, result) ->
            if error
                alert "Can't remove round. " + error.reason
