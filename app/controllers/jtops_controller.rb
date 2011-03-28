class JtopsController < ApplicationController
  def index
    redirect_to jtop_path(Jtop.last)
  end

  def list

  end

  def show

  end
end
