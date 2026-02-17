module Imports
  module Warranties
    class Builder
      def self.empty_row
        {
          client: "",
          commit: "",
          user_id: nil,
          product_id: nil,
          state: "pending"
        }
      end
    end
  end
end
