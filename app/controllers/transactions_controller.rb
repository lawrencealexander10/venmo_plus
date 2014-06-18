class TransactionsController < ApplicationController
  def new
  end

  def create
  	@transfer = Transfer.new
  end

  def edit
  end

  def update
  end
end


      # <ul class="list-group">
      #           <li class="list-group-item">item 1 for $x <%=link_to 'Make Payment!', '/transfers/create', :class => "btn btn-primary btn-sm active pay date_payment_due", :method => :get%></li>
      #           <li class="list-group-item">item 2 for $x <%=link_to 'Make Payment!', '/transfers/create', :class => "btn btn-primary btn-sm active pay date_payment_due", :method => :get%></li>
      #           <li class="list-group-item">item 3 for $x <%=link_to 'Make Payment!', '/transfers/create', :class => "btn btn-primary btn-sm active pay date_payment_due", :method => :get%></li>
      #           <li class="list-group-item">item 4 for $x <%=link_to 'Make Payment!', '/transfers/create', :class => "btn btn-primary btn-sm active pay date_payment_due", :method => :get%></li>
      #           <li class="list-group-item">item 5 for $x <%=link_to 'Make Payment!', '/transfers/create', :class => "btn btn-primary btn-sm active pay date_payment_due", :method => :get%></li>
      #       </ul>