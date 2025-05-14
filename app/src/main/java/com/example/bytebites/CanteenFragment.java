package com.example.bytebites;

import android.os.Bundle;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import java.util.ArrayList;
import java.util.List;

public class CanteenFragment extends Fragment {

    private RecyclerView recyclerView;
    private CanteenAdapter adapter;
    private List<Canteen> canteenList;

    public CanteenFragment() {}

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_canteen, container, false);

        recyclerView = view.findViewById(R.id.recyclerViewCanteens);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));

        canteenList = new ArrayList<>();
        canteenList.add(new Canteen("Techno Edge", "Cheap and popular", 4.2f));
        canteenList.add(new Canteen("Deck", "Variety of stalls", 4.0f));
        canteenList.add(new Canteen("PGP Canteen", "Near residence, limited options", 3.8f));

        adapter = new CanteenAdapter(canteenList);
        recyclerView.setAdapter(adapter);

        return view;
    }
}
