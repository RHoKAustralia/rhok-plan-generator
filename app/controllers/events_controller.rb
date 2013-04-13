class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def create
    @event = Event.new(params[:event])
    if @event.save
      redirect_to @event, :notice => "Successfully created event."
    else
      render :action => 'new'
    end
  end

  def show
    @event = Event.find(params[:id])
    @task = @event.tasks.first
    @person = @task.people.first
    # mailer = PersonMailer.welcome_email(@event, @person, @task)
    # @msg = mailer.deliver

    ses = AWS::SimpleEmailService.new(
      # these two env var *names* are preset by Elastic Beastalk and have been given values via the AWS Console
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_KEY']) 

    # only required for sandbox ses usage
    identity = ses.identities.verify(@person.email)
    puts "identity.verified? #{identity.verified?}"


    ses.send_email(
      :subject => "A Sample Email #{Time.now}",
      :from => 'jkelabora@dius.com.au',
      :to => @person.email,
      :body_text => 'Sample email text.',
      :body_html => "<h1>Sample Email #{Time.now}</h1>")


    @account_sid = 'AC6ef2afcab7f0748e9fc427288cdd5f8d'
    @auth_token = ENV['PARAM1']

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)

    @account = @client.account
    @msg = @account.sms.messages.create({:from => '+19402028234', :to =>  @person.mobile, :body => 'rhok-and-roll!'})
    puts @msg
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      redirect_to @event, :notice  => "Successfully updated event."
    else
      render :action => 'edit'
    end
  end
end
