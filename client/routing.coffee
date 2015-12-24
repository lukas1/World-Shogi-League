@Routes =
    home:
        path: '/'
        template: 'home'
        name: 'home'
    oops:
        template: 'oops'
    games:
        path: 'matches/games/:_id'
        template: 'games'
        name: 'games'
    kifu:
        path: 'matches/games/kifu/:_id'
        template: 'kifu'
        name: 'kifu'
    login:
        path: '/user/login',
        template: 'loginform'
        name: 'user.login'
    registration:
        path: '/user/registration'
        template: 'registration'
        name: 'user.registration'
    resetPassword:
        path: '/user/resetPassword/:_id'
        template: 'resetpassword'
        name: 'user.resetPassword'
    teamsEdit:
        path: '/teams/edit'
        template: 'teamsedit'
        name: 'teams.edit'
    teamProfile:
        path: '/teams/team-profile/:_id'
        template: 'teamProfile'
        name: 'team.profile'
    userList:
        path: '/user/list'
        template: 'userlist'
        name: 'user.list'
    updateUser:
        path: '/user/update'
        template: 'updateuser'
        name: 'user.update'
    userProfile:
        path: '/user/profile/:_id'
        template: 'userProfile'
        name: 'user.profile'
    scheduleMatch:
        path: '/matches/schedule'
        template: 'scheduleMatch'
        name: 'matches.schedule'
    notAssigned:
        template: 'notAssigned'
