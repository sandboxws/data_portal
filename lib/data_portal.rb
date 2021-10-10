require 'rails'
require 'awesome_print'

require 'data_portal/version'
require 'data_portal/railtie'

# Attributes
require 'data_portal/attributes/standard'
require 'data_portal/attributes/count'
require 'data_portal/attributes/standalone'

# Relations
require 'data_portal/relations/standard'

# Providers
require 'data_portal/provider'

# Views
require 'data_portal/view'

# Renderer
require 'data_portal/view_renderer'

module DataPortal
  # Your code goes here...
end
