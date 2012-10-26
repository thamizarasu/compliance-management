# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Controls
class ControlsController < ApplicationController
  include ApplicationHelper
  include ControlsHelper
  include AuthorizationHelper

  before_filter :load_control, :only => [:show,
                                         :edit,
                                         :tooltip,
                                         :update,
                                         :sections,
                                         :implemented_controls,
                                         :implementing_controls,
                                         :delete,
                                         :destroy]


  access_control :acl do
    allow :superuser

    actions :new, :create do
      allow :create, :create_control
    end

    actions :edit, :update do
      allow :update, :update_control, :of => :control
    end

    actions :show, :tooltip do
      allow :read, :read_control, :of => :control
    end

    actions :index do
      allow :read, :read_control
    end

    actions :sections, :implemented_controls, :implementing_controls do
      allow :read, :read_control, :of => :control
    end
  end

  layout 'dashboard'

  def index
    @controls = Control
    if params[:s].present?
      @controls = @controls.db_search(params[:s])
    end
    @controls = allowed_objs(@controls.all, :read)

    render :json => @controls
  end

  def show
  end

  def new
    @control = Control.new(control_params)

    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def tooltip
    render :layout => nil
  end

  def create
    @control = Control.new(control_params)

    respond_to do |format|
      if @control.save
        flash[:notice] = "Successfully created a new control"
        format.json do
          render :json => @control.as_json(:root => nil), :location => flow_control_path(@control)
        end
        format.html { redirect_to flow_control_path(@control) }
      else
        flash[:error] = "There was an error creating the control."
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    respond_to do |format|
      if @control.authored_update(current_user, control_params)
        flash[:notice] = "Successfully updated the control!"
        format.json do
          render :json => @control.as_json(:root => nil), :location => flow_control_path(@control)
        end
        format.html { redirect_to flow_control_path(@control) }
      else
        flash[:error] = "There was an error updating the control"
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def delete
    @model_stats = []
    @relationship_stats = []
    @model_stats << [ 'System Control', @control.system_controls.count ]
    @relationship_stats << [ 'Section', @control.control_sections.count ]
    @relationship_stats << [ 'Implemented Control', @control.implemented_controls.count ]
    @relationship_stats << [ 'Implementing Control', @control.implementing_controls.count ]
    @relationship_stats << [ 'Document', @control.documents.count ]
    @relationship_stats << [ 'Category', @control.categories.count ]
    @relationship_stats << [ 'Person', @control.people.count ]
    respond_to do |format|
      format.json { render :json => @control.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @control, :url => flow_control_path(@control), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @control.destroy
    flash[:notice] = "Control deleted"
    respond_to do |format|
      format.html { redirect_to flow_program_path(@control.program) }
      format.json { render :json => @control.as_json(:root => nil) }
    end
  end

  def sections
    @sections =
      @control.sections.all +
      @control.implemented_controls.includes(:sections).map(&:sections).flatten
    @sections = allowed_objs(@sections, :read)
    @sections.sort_by(&:slug_split_for_sort)
    render :layout => nil, :locals => { :sections => @sections }
  end

  def implemented_controls
    @controls = @control.implemented_controls
    if params[:s]
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls.all.sort_by(&:slug_split_for_sort)
    render :action => 'controls', :layout => nil, :locals => { :controls => @controls, :prefix => 'Parent of' }
  end

  def implementing_controls
    @controls = @control.implementing_controls
    if params[:s]
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls.all.sort_by(&:slug_split_for_sort)
    render :action => 'controls', :layout => nil, :locals => { :controls => @controls, :prefix => 'Child of' }
  end

  private
    def load_control
      @control = Control.find(params[:id])
    end
end
