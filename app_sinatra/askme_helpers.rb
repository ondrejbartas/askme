# -*- encoding : utf-8 -*-
class AskmeSinatra < Sinatra::Base

  helpers do
    def include_javascripts
      out = ""
      Assets.javascripts.each do |name|
        out += "<script type=\"text/javascript\" language=\"javascript\" src=\"/javascripts/#{name}.js\"></script>\n"
  		end
      out
    end

    def include_stylesheets
      out = ""
      Assets.stylesheets.each do |name|
        out += "<link rel=\"stylesheet\" href=\"/stylesheets/#{name}.css\" />\n"
  		end
      out
    end
    
    def html template
      template_file = File.join(options.views, template.to_s+'.html')
      if File.exists?(template_file)
        File.read(template_file)
      else
        raise "Template '#{template}' couldn't be found in #{options.views}"
      end
    end
        
  end

end