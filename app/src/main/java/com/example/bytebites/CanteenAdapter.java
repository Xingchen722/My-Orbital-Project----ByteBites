package com.example.bytebites;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class CanteenAdapter extends RecyclerView.Adapter<CanteenAdapter.CanteenViewHolder> {

    private List<Canteen> canteenList;

    public CanteenAdapter(List<Canteen> canteenList) {
        this.canteenList = canteenList;
    }

    @NonNull
    @Override
    public CanteenViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.canteen_item, parent, false);
        return new CanteenViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull CanteenViewHolder holder, int position) {
        Canteen canteen = canteenList.get(position);
        holder.name.setText(canteen.getName());
        holder.description.setText(canteen.getDescription());
        holder.rating.setText("Rating: " + canteen.getRating());
    }

    @Override
    public int getItemCount() {
        return canteenList.size();
    }

    static class CanteenViewHolder extends RecyclerView.ViewHolder {
        TextView name, description, rating;

        CanteenViewHolder(View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.canteenName);
            description = itemView.findViewById(R.id.canteenDescription);
            rating = itemView.findViewById(R.id.canteenRating);
        }
    }
}
