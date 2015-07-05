Router.configure({
    layoutTemplate:"applicationLayout"
})

Router.route('/', () ->
    this.render('matches');
)

Router.route(Routes.login.path, () ->
    this.render(Routes.login.template);
)

Router.route(Routes.teamsEdit.path, () ->
    this.render(Routes.teamsEdit.template);
)
