class ToolsController < ApplicationController
  before_action :set_tool, only: %i[show edit update destroy reset_date_of_use reset_date_of_use]
  before_action :authenticate_user!, except: %i[show index update show reset_date_of_use update_date_of_use]


  # GET /tools or /tools.json
  def index
    @tools = visible_tools_scope

    if params[:search]
      search_term = "%#{params[:search]}%"
      @tools = @tools.where("id_tool ILIKE ? OR precinto ILIKE ? OR clase ILIKE ?", search_term, search_term, search_term)
    end

    if params[:due_soon].present?
      @tools = @tools.where(date_due_to: Date.current..30.days.from_now.to_date)
    end

    if params[:used_only].present?
      @tools = @tools.where.not(date_of_use: nil)
    end

    case params[:sort_due_to]
    when 'desc'
      @tools = @tools.order(date_due_to: :desc)
    when 'asc'
      @tools = @tools.order(date_due_to: :asc)
    end

    paginate_tools
  end

  def used_tools
    redirect_to tools_path(request.query_parameters.merge(used_only: true))
  end


  # GET /tools/1 or /tools/1.json
  def show
  end

  # GET /tools/new
  def new
    @tool = current_user.tools.build
  end

  # GET /tools/1/edit
  def edit
  end

  # POST /tools or /tools.json
  def create
    @tool = current_user.tools.build(tool_params)

    respond_to do |format|
      if @tool.save
        log_tool_event(@tool, "Se creo el item #{@tool.id_tool}. #{format_event_date(Time.current)} por #{event_actor_name}.")
        format.html { redirect_to tool_url(@tool), notice: 'Tool was successfully created.' }
        format.json { render :show, status: :created, location: @tool }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tools/1 or /tools/1.json
  def update
    respond_to do |format|
      if @tool.update(tool_params)
        log_tool_changes(@tool)
        format.html { redirect_to tool_url(@tool), notice: 'Tool was successfully updated.' }
        format.json { render :show, status: :ok, location: @tool }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tools/1 or /tools/1.json
  def destroy
    log_tool_event(@tool, "Se borro el item #{@tool.id_tool}. #{format_event_date(Time.current)} por #{event_actor_name}.")
    @tool.destroy

    respond_to do |format|
      format.html { redirect_to tools_url, notice: 'Tool was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def correct_user
    @tool = current_user.tools.find_by(id: params[:id])
    redirect_to tools_path, notice: 'Not Authorized To Edit This Tool' if @tool.nil?
  end

  def reset_date_of_use
    @tool = Tool.find(params[:id])
    @tool.update(date_of_use: nil, date_due_to: nil)
    log_tool_event(@tool, "Se borraron la fecha de uso y la fecha de vencimiento. #{format_event_date(Time.current)} por #{event_actor_name}.")

    respond_to do |format|
      format.html { redirect_to tool_url(@tool), notice: 'Date of use reset successfully.' }
      format.json { render :show, status: :ok, location: @tool }
    end
  end

  def update_date_of_use
    @tool = Tool.find(params[:id])
    if params[:reset_date_of_use]
      @tool.update(date_of_use: nil, date_due_to: nil)
      redirect_to tool_url(@tool), notice: 'Date of use reset successfully.'
    else
      if @tool.can_update_date_of_use? && @tool.update(tool_params)
        redirect_to tool_url(@tool), notice: 'Tool was successfully updated.'
      else
        # Handle update errors
      end
    end


  def correct_user
    @tool = Tool.find(params[:id])
    unless current_user.admin? || @tool.user == current_user
      redirect_to tools_path, notice: 'Not Authorized'
    end
  end


end


  private

  def visible_tools_scope
    return Tool.none unless user_signed_in?

    current_user.tools
  end

  def log_tool_changes(tool)
    tool.saved_changes.except(:updated_at, :created_at).each do |attribute, values|
      from_value, to_value = values
      next if from_value == to_value

      log_tool_event(tool, build_change_message(attribute, from_value, to_value))
    end
  end

  def build_change_message(attribute, from_value, to_value)
    date = format_event_date(Time.current)
    actor = event_actor_name

    case attribute.to_sym
    when :date_of_use
      if from_value.blank? && to_value.present?
        "Se agrego nueva fecha de uso #{format_date_value(to_value)}. #{date} por #{actor}."
      elsif to_value.blank?
        "Se elimino la fecha de uso que era #{format_date_value(from_value)}. #{date} por #{actor}."
      else
        "La fecha de uso fue cambiada de #{format_date_value(from_value)} a #{format_date_value(to_value)}. #{date} por #{actor}."
      end
    when :date_due_to
      if from_value.blank? && to_value.present?
        "Se agrego nueva fecha de vencimiento #{format_date_value(to_value)}. #{date} por #{actor}."
      elsif to_value.blank?
        "Se elimino la fecha de vencimiento que era #{format_date_value(from_value)}. #{date} por #{actor}."
      else
        "La fecha de vencimiento fue cambiada de #{format_date_value(from_value)} a #{format_date_value(to_value)}. #{date} por #{actor}."
      end
    when :link_to_pdf
      "El valor de Inspeccion fue cambiado de #{format_text_value(from_value)} a #{format_text_value(to_value)}. #{date} por #{actor}."
    when :location
      "La ubicacion fue cambiada de #{format_text_value(from_value)} a #{format_text_value(to_value)}. #{date} por #{actor}."
    else
      "El campo #{human_attribute_name(attribute)} fue cambiado de #{format_text_value(from_value)} a #{format_text_value(to_value)}. #{date} por #{actor}."
    end
  end

  def log_tool_event(tool, description)
    Event.create!(
      tool_id: tool.id,
      tool_code: tool.id_tool,
      user_name: event_actor_name,
      description: description
    )
  end

  def event_actor_name
    current_user&.display_name || 'Sistema'
  end

  def format_event_date(value)
    value.strftime('%d/%m/%Y')
  end

  def format_date_value(value)
    value.present? ? value.to_date.strftime('%d/%m/%Y') : 'vacio'
  end

  def format_text_value(value)
    value.present? ? value.to_s : 'vacio'
  end

  def human_attribute_name(attribute)
    {
      id_tool: 'ID',
      precinto: 'Precinto',
      clase: 'Clase',
      pin: 'Pin',
      box: 'Box',
      location: 'Ubicacion'
    }.fetch(attribute.to_sym, attribute.to_s.humanize)
  end

  def paginate_tools
    @per_page = 50
    @current_page = [params.fetch(:page, 1).to_i, 1].max
    @total_tools = @tools.count
    @total_pages = [(@total_tools.to_f / @per_page).ceil, 1].max

    @current_page = @total_pages if @current_page > @total_pages

    offset = (@current_page - 1) * @per_page
    @tools = @tools.offset(offset).limit(@per_page)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_tool
    @tool = Tool.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def tool_params
    # Ensure date fields are set to nil if they are submitted blank
    params.require(:tool).permit(:id_tool, :precinto, :link_to_pdf, :clase, :pin, :box, :location, :location_option, :location_detail, :date_of_use, :date_due_to, :days_left, :state)
          .tap do |whitelisted|
            whitelisted[:date_of_use] = nil if whitelisted[:date_of_use].blank?
            whitelisted[:date_due_to] = nil if whitelisted[:date_due_to].blank?
            whitelisted[:location] = build_location_value(whitelisted.delete(:location_option), whitelisted.delete(:location_detail), whitelisted[:location])
          end
  end

  def build_location_value(location_option, location_detail, current_location)
    option = location_option.to_s.strip
    detail = location_detail.to_s.strip

    return current_location if option.blank?
    return current_location if option == 'Pozo' && detail.blank? && current_location.present? && current_location.start_with?('Pozo ')
    return 'Pozo' if option == 'Pozo' && detail.blank?
    return "Pozo #{detail}".strip if option == 'Pozo' && detail.present?

    option
  end
end
