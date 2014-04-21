require 'prawn'

class PlansController < ApplicationController

  respond_to :json, :html

  def duplicate
    @duplicate = Plan.find_by_public_guid(params[:public_guid]).duplicate

    if @duplicate.save
      respond_to do |format|
        format.html { redirect_to plan_edit_path(@duplicate.private_guid) }
        format.json { render :js => "#{plan_edit_path(@duplicate.private_guid)}" }
      end

    else
      redirect_to home_index_path, :notice  => "Problem duplicating plan"
    end
  end

  def download
    @plan = Plan.find_by_private_guid(params[:private_guid]).decorate

    prawnto :filename => "#{@plan.display_name}.pdf",
            :prawn    => { :info => {
                           :Title => "#{@plan.display_name}",
                           :Creator => "whatstheplan.net",
                           :CreationDate => Time.now }
                         }

    respond_to do |format|
      format.pdf { render :layout => false}
    end
  end

  def show
    @plan = Plan.find_by_public_guid(params[:public_guid]).decorate
  end

  def edit
    @plan = Plan.find_by_private_guid(params[:private_guid])
    plan = {owner: @plan.people.first, plan: @plan, events: [], kits: []}

    # Sorry about this.
    # This should really be a different category or something, flagged in the datadase
    other_matcher = "Kit|Contact"
    events = @plan.decorate.events

    normal_events = events.select {|event| not event.name.match other_matcher }
    normal_events.each do |event|
      plan[:events] << {
        event: event,
        custom_tasks: @plan.decorate.tasks_for(event),
        public_tasks: @plan.decorate.suggested_tasks_for(event)
      }
    end

    kits = events.select {|event| event.name.match other_matcher }
    kits.each do |event|
      plan[:kits] << {
        event: event,
        custom_tasks: @plan.decorate.tasks_for(event),
        public_tasks: @plan.decorate.suggested_tasks_for(event)
      }
    end

    gon.plan = plan
    render :action => 'edit'
  end

  def update
    @plan = Plan.find_by_private_guid(params[:private_guid])
    if params[:name]
      @plan.name = params[:name]
      if @plan.save
        render :json => params[:name]
      else
        @plan.reload
        render :json => @plan.name # re-render original
      end
    end
    if params[:postcode]
      @plan.postcode = params[:postcode]
      if @plan.save
      # todo: altering the postcode of a copied plan will mean the traversal in the visualisation will break..
        render :json => params[:postcode]
      else
        @plan.reload
        render :json => @plan.postcode # re-render original
      end
    end
  end

end
