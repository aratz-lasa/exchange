defmodule Exchange.Execute do
    alias Exchange.Director

    # sign-in
    def execute({1, data}) do
        user = String.split(data, "#") 
        case user do
            [username, password] -> 
                User.to_struct(user)
                 |> Director.sign_in
            _ -> {:error, "Invalid input"}
        end
    end
    
    # log-in
    def execute({2, data}) do
        user = String.split(data, "#") 
        case user do
            [username, password] -> 
                User.to_struct(user)
                |> Director.log_in
            _ -> {:error, "Invalid input"}
        end
    end

    # retrieve unread data
    def execute({3, data}) do
            
    end

    ## HOST
    # sign exchange
    def execute({4, data}) do
        
    end
    
    # connect host to exchange
    def execute({5, data}) do
            
    end

    # add good to exhchange
    def execute({6, data}) do
            
    end

    # accept offer
    def execute({7, data}) do
            
    end

    # decline offer
    def execute({8, data}) do
                
    end

    # send message to guest
    def execute({9, data}) do
            
    end

    # purge exchange
    def execute({10, data}) do
            
    end

    # purge guest from exchange
    def execute({11, data}) do
            
    end

    ## GUEST
    # connect to exchange
    def execute({12, data}) do
        
    end

    # leave exchange
    def execute({13, data}) do
            
    end

    # get exchange goods
    def execute({14, data}) do
            
    end

    # send offer to host
    def execute({15, data}) do
            
    end

    # send message to host
    def execute({16, data}) do
            
    end
end