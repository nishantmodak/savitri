class ReadController < ApplicationController
  def index
  	#@cantos = Canto.includes("stanzas").includes("lines").order("cantono").page(params[:cantos]).per(1)
  	#@lines = Line.order("no").page(params[:cantos]).per(5)
  	@stanzas = Stanza.includes("lines").order("stanzno").page(params[:stanzas]).per(4)
  end
end
