tplRound = () ->
    Template.instance().data.round

Template.addMatch.helpers
    selectedClass: ->
        Template.instance().selectedClass.get()

Template.addMatch.onCreated ()->
    this.selectedClass = new ReactiveVar("")

Template.addMatch.rendered = ->
    this.selectedClass.set("")


Template.addMatch.events
    "submit .new-match-form": (event, tpl) ->
        event.preventDefault()
        return false if not isAdmin()

        formId = "new-match-form" + tplRound()
        return false if formId != $(event.target).attr('id')

        teamBSelector = "#class" + tpl.selectedClass.get() + "Team" + tplRound()

        # Get values
        teamAId = tpl.$("#classTeam" + tplRound()).val()
        teamBId = tpl.$(teamBSelector).val()

        # validate
        return false if not teamAId?.length or not teamBId?.length
        if teamAId == teamBId
            alert "Select two different teams to play against each other!"
            return false

        roundId = tpl.$('.matchRound').val()
        if not roundId?.length
            alert "Unexpected error while adding match. Please refresh the page
            and try again. In case the problem persists, please contact the
            administrator."
            return false

        matchEndDate = moment().add(8, 'days').toDate()

        matchId = Matches.insertMatch(
            teamAId: teamAId
            teamBId: teamBId
            class: tpl.selectedClass.get()
            createdAt: new Date()
            matchEndDate: matchEndDate
            roundId: roundId
        )


        return false if not matchId

        # Clear form
        tpl.$("#classATeam" + tplRound()).prop('selectedIndex', 0);
        tpl.$("#classBTeam" + tplRound()).prop('selectedIndex', 0);

        # Prevent default form submit
        return false

    "change .teamSelect": (event, tpl) ->
        event.preventDefault()
        selector = "#classTeam" + tplRound()
        return false if ('#' + $(event.target).attr('id') != selector)

        teamId = tpl.$(selector).val()
        team = Teams.findOne teamId
        tpl.selectedClass.set team?.class
