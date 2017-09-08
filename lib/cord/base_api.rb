require_relative 'dsl'
module Cord
  class BaseApi
    include DSL
    include ActiveSupport::Callbacks

    define_callbacks :before_action

    def self.before_action &block
      set_callback :before_action, :before, &block
    end

    def run_before_callbacks
      run_callbacks :before_action
    end


    # class Record
    #
    #   def save
    #     run_callbacks :save do
    #       puts "- save"
    #     end
    #   end
    # end
    #
    # class PersonRecord < Record
    #   set_callback :save, :before, :saving_message
    #   def saving_message
    #     puts "saving..."
    #   end
    #
    #   set_callback :save, :after do |object|
    #     puts "saved"
    #   end
    # end



    def initialize controller, params
      @controller = controller
      @params = params
    end

    def controller
      @controller
    end

    def ids
      ids = {all: driver.all.map(&:id)}
      scopes.each do |name, block|
        ids[name] = model.instance_exec(&block).all.map(&:id)
      end
      render ids: ids
      @response
    end

    def get(options={})
      records = driver.all
      records = records.where(id: options[:ids]) if (options[:ids].present?)

      if (options[:attributes].present?)
        allowed_attributes = white_list_attributes(options[:attributes])
        records_json = []
        records.each do |record|
          if columns.any?
            record_json = record.as_json({only: columns, except: ignore_columns})
          else
            record_json = record.as_json({except: ignore_columns})
          end
          allowed_attributes.each do |attr_name|
            record_json[attr_name] = instance_exec(record, &attributes[attr_name])
          end
          records_json.append(record_json)
        end
      else
        if (columns.any?)
          records_json = records.as_json({only: columns, except: ignore_columns})
        else
          records_json = records.as_json({except: ignore_columns})
        end
      end

      render records: records_json
      @response
    end

    def perform action_name
      if ids = params[:ids]
        action = member_actions[action_name]
        driver.where(id: ids).find_each do |record|
          instance_exec(record, &action)
        end
      else
        action = collection_actions[action_name]
        if (action)
          instance_exec &action
        else
          error('no action found')
        end
      end
      @response
    end

    protected

    def params
      @params
    end

    def render data
      @response ||= {}
      @response.merge! data
    end

    def redirect path
      render status: :redirect, url: path
    end

    def error message
      render error: message
    end

    def error_for record, message
      render error_for: { record: record, message: message}
    end

    private

    def white_list_attributes(attrs)
      blacklist = attrs - attribute_names - model.column_names
      error("Unknown attributes: #{blacklist.join(', ')}") if blacklist.any?
      attrs & attribute_names
    end

  end
end
