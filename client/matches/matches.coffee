Template.matches.helpers(
    matches: (roundId) ->
        Matches.find {roundId: roundId}, { sort: { class: 1, createdAt: 1 } }
    rounds: () ->
        rounds = Rounds.find({}, {sort: {createdAt: 1}}).fetch()

        # Display delete button only for the last round
        # Only last round can be removed
        _.extend(_.last(rounds), {"last": true}) if rounds?.length

        return rounds
    isAdmin: () ->
        isAdmin()
    inMiddleOfRound: () ->
        lRound = lastRound()
        if lRound?
            roundNumber = lRound?.roundNumber
            finished = lRound?.finished
            return finished
        else
            return true
    canAddMatch: () ->
        lRound = lastRound()
        return false if not lRound?
        roundNumber = lRound?.roundNumber
        finished = lRound?.finished
        return not finished
)

Template.matches.events
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
