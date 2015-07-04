Router.configure({
    layoutTemplate:"applicationLayout"
});

Router.route('/', function () {
  this.render('matches');
});

Router.route(Routes.login.path, function() {
    this.render(Routes.login.template);
})
