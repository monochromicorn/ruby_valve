require 'ruby_valve/errors'

module RubyValve
  class Base
    attr_reader :executed_steps

    def execute
      # begin

      # send(:before_all) if respond_to?(:before_all)

      execution_order.each do |_method|
        if !skip?(_method)
          # send(:before_each)           if respond_to?(:before_each)
          # send(before_method(_method)) if respond_to?(before_method(_method)) && !skip?(before_method(_method))
          
          send(_method)      
          log_step_execution(_method)

          # send(after_method(_method))  if respond_to?(after_method(_method))  && !skip?(after_method(_method))
          # send(:after_each)            if respond_to?(:after_each)          
        end
      end
    #   send(:after_success) if respond_to?(:after_success) && !abort_triggered?
    #   send(:after_abort)    if respond_to?(:after_abort)    && abort_triggered?
    #   send(:after_all) if respond_to?(:after_all) && !skip?(:after_all)
    # rescue OperationAbortError
    #   send(:after_fail)    if respond_to?(:after_fail)    && abort_triggered?    
    #   raise e
    # rescue => e
    #   if respond_to?(:after_exception)
    #     send(:after_exception, e)
    #   else
    #     raise e
    #   end
    # end
    #   send(:response)
    end

     

      def response
        @response
      end

      #=> logging methods
      def log_step_execution(_method)
        (@executed_steps ||= []) << _method
        log_execution(_method)
      end

      def log_execution(_method)
        (@executed ||= []) << _method
      end

      def abort(message, options = {})
        @abort_triggered = true
        @abort_message = message 
        raise(OperationAbortError, abort_message) if options[:raise]
      end

      #=> skip methods
      def skip_all_steps?
        abort_triggered?
      end

      def skip(*step_names)
        skip_list += step_names
      end

      def abort_triggered?
        @abort_triggered
      end

      def skip?(method_name)
        return true if skip_all_steps?

        skip_list.include?(method_name)
      end

      def skip_list
        @skip_list ||= []
      end

      def execution_order
        step_methods = methods.select {|meth| meth.to_s.match(/^step_[0-9]*$/)}

        step_methods.sort do |x,y|
          ordinal_x = x.to_s.split("_").last.to_i
          ordinal_y = y.to_s.split("_").last.to_i

          ordinal_x <=> ordinal_y
        end
      end

      def before_method(_method)
        :"before_#{_method}"
      end

      def after_method(_method)
        :"after_#{_method}"
      end
  end  
end