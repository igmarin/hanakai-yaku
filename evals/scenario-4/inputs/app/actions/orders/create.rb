# frozen_string_literal: true

module MyApp
  module Actions
    module Orders
      class Create < MyApp::Action
        include Deps["repos.order_repo"]

        params do
          required(:order).hash do
            required(:customer_name).value(:string, min_size?: 1)
            required(:customer_email).value(:string, format?: /\A.+@.+\z/)
            required(:total_cents).value(:integer, gt?: 0)
          end
        end

        def handle(request, response)
          order = order_repo.create(request.params[:order])
          response.status = 201
          response.format = :json
          response.body = order.to_json
        end
      end
    end
  end
end
