class PostsController < ApplicationController

  before_filter :store_location
  before_filter :authenticate_user!, :except => [:show, :index]
  
  load_and_authorize_resource

  # GET /posts
  # GET /posts.json
  def index
    @blog_id = Blog.find_by_slug(params[:blog_id]).id
    if params[:tag]
      @posts = Post.tagged_with(params[:tag]).where(:blog_id=>@blog_id)
    else
      @posts = Post.where(:blog_id=>@blog_id).order("created_at DESC")
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])
    puts @post.inspect
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Post.new 
    #logger.info "count is"+@counter.count
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(params[:post])
    #@blog=Blog.find_by_slug(params[:post][:blog_id])
    #@post.blog_id = @blog.id   
    #@post = @blog.build(params[:post])

    respond_to do |format|
      if @post.save
        #EmailWorker.perform_async(current_user.id)
        format.html { redirect_to blog_posts_path(@post.blog), notice: 'Post was successfully created.' }
        format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])
    @blog=Blog.find_by_slug(params[:post][:blog_id])
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to blog_post_path(@post.blog,@post), notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to blog_posts_path(@post.blog) }
      format.json { head :no_content }
    end
  end

end
