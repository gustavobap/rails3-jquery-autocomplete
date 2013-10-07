module Rails3JQueryAutocomplete
  module Orm
    module ActiveRecord
      def get_autocomplete_order(method, options, model=nil)
        order = options[:order]

        table_prefix = model ? "#{model.table_name}." : ""
        order || "#{table_prefix}#{method} ASC"
      end

      def get_autocomplete_items(parameters)
        model   = parameters[:model]
        term    = parameters[:term]
        search_extra_params = parameters[:search_extra_params]
        method  = parameters[:method]
        options = parameters[:options]
        search_scope = options[:search_scope]
        scopes  = Array(options[:scopes])
        search_method = options[:search_method]
        where   = options[:where]
        limit   = get_autocomplete_limit(options)
        order   = get_autocomplete_order(method, options, model)


        items = model.scoped

        scopes.each { |scope| items = items.send(scope, term, search_extra_params) } unless scopes.empty?

        items = items.select(get_autocomplete_select_clause(model, method, options)) unless options[:full_model]
<<<<<<< HEAD
        
        if(search_method)
          items = items.send(search_method, term, search_extra_params)
        else
          items = items.where(get_autocomplete_where_clause(model, term, method, options))
        end
        
        items = items.limit(limit).order(order)
        
=======

        if search_scope.blank?
          items = items.where(get_autocomplete_where_clause(model, term, method, options))
        else
          items = items.send(search_scope, get_autocomplete_term_for_like(term, options))
        end

        items = items.limit(limit).order(order)
>>>>>>> b66924f4dd4dbacd2c2897798c60a0a14af744da
        items = items.where(where) unless where.blank?

        puts items.to_sql

        items
      end

      def get_autocomplete_select_clause(model, method, options)
        table_name = model.table_name
        (["#{table_name}.#{model.primary_key}", "#{table_name}.#{method}"] + (options[:extra_data].blank? ? [] : options[:extra_data]))
      end

      def get_autocomplete_where_clause(model, term, method, options)
        table_name = model.table_name
        like_clause = (postgres?(model) ? 'ILIKE' : 'LIKE')
        ["LOWER(#{table_name}.#{method}) #{like_clause} ?", get_autocomplete_term_for_like(term, options)]
      end

      def get_autocomplete_term_for_like(term, options)
        is_full_search = options[:full]
        "#{(is_full_search ? '%' : '')}#{term.downcase}%"
      end

      def postgres?(model)
        # Figure out if this particular model uses the PostgreSQL adapter
        model.connection.class.to_s.match(/PostgreSQLAdapter/)
      end
    end
  end
end
