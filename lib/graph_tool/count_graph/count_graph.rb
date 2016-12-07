require 'pry-byebug'
class GraphTool::CountGraph < GraphTool::Graph
  def default_options
    super.merge(
      columns:          10,
      item_width:       20,
      item_height:      20,
      inner_margin:     2,
      outer_margin:     20,
      background_color: 'white'
    )
  end

  def validate_arguments(data, options)
    super(data, options)
    raise ArgumentError unless data.is_a? Array
    raise ArgumentError unless data.all? { |x| Integer(x) }
    raise ArgumentError if item_and_color_input_differ(data, options)
  end

  def item_and_color_input_differ(data, options)
    options[:colors] && data.count != options[:colors].count
  end

  def prepare_data
    prepared_data = []
    data.each_with_index do |value, index|
      value.to_i.times { prepared_data << colors[index].to_s }
    end
    prepared_data.each_slice(columns).to_a
  end

  def draw
    draw_background_color(width, height, background_color)
    prepared_data.each_with_index do |row, row_count|
      row.each_with_index do |color, column_count|
        x = offset_x(column_count) + inner_margin + outer_margin
        y = offset_y(row_count) + inner_margin + outer_margin
        draw_item(x, y, color)
      end
    end
    draw_label
  end

  def draw_label
    data.each_with_index do |data, index| 
      x = inner_margin + outer_margin
      y = offset_y(prepared_data.count + (index + 1)) + inner_margin + outer_margin
      draw_item(x, y, options[:colors][index])
      draw_label_text(x, y, options[:labels][index]) # expand total image size according to labels
    end
  end

  def draw_background_color(width, height, color)
    x, y = 0, 0
    renderer.rect x, y, width, height, fill: color, class: 'background_color'
  end

  def offset_x(column_count)
    column_count * outer_item_width
  end

  def offset_y(row_count)
    row_count * outer_item_height
  end

  def outer_item_width
    item_width + 2 * inner_margin
  end

  def outer_item_height
    item_height + 2 * inner_margin
  end

  def draw_item(_x, _y, _color)
    raise NotImplementedError
  end

  def width
    prepared_data.first.count * outer_item_width + (2 * outer_margin) # + label_count?
  end

  def height
    (prepared_data.count + label_count) * outer_item_height + (2 * outer_margin)
  end

  def label_count
    if options[:labels]
      labels.count
    else
      0
    end
  end
end
