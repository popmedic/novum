package com.novumconcepts.fieldClient;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.SharedPreferences;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.app.ActionBar;
import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.os.Build;
import android.widget.EditText;

public class SettingsActivity extends ActionBarActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        if (savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction()
                    .add(R.id.container, new PlaceholderFragment())
                    .commit();
        }
    }

    @Override
    protected void onStop(){
        /*SharedPreferences preferences = this.getSharedPreferences(
                String.valueOf(R.string.shared_pref_file), Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();

        EditText nameText = (EditText)(findViewById(R.id.nameText));
        //EditText phoneNumberText = (EditText)(findViewById(R.id.phoneNumberText));
        EditText agencyText = (EditText)(findViewById(R.id.agencyText));
        EditText unitText = (EditText)(findViewById(R.id.unitText));

        String name = nameText.getText().toString();
        //String phoneNumber = phoneNumberText.getText().toString();
        String agency = agencyText.getText().toString();
        String unit = unitText.getText().toString();

        editor.putString("name", name);
        //editor.putString("phoneNumber", phoneNumber);
        editor.putString("agency", agency);
        editor.putString("unit", unit);

        editor.commit();*/

        super.onStop();
    }

    public void validateSettings(String name, String agency, String unit) throws Exception{
        if(name.equals("")){
            throw new Exception(getString(R.string.validate_settings_name_failure));
        }
        if(agency.equals("")){
            throw new Exception(getString(R.string.validate_settings_agency_failure));
        }
        if(unit.equals("")){
            throw new Exception(getString(R.string.validate_settings_unit_failure));
        }
    }

    public void applyButtonClick(View view){
        try{
            SharedPreferences preferences = this.getSharedPreferences(
                    String.valueOf(R.string.shared_pref_file), Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = preferences.edit();

            EditText nameText = (EditText)(findViewById(R.id.nameText));
            //EditText phoneNumberText = (EditText)(findViewById(R.id.phoneNumberText));
            EditText agencyText = (EditText)(findViewById(R.id.agencyText));
            EditText unitText = (EditText)(findViewById(R.id.unitText));

            String name = nameText.getText().toString();
            //String phoneNumber = phoneNumberText.getText().toString();
            String agency = agencyText.getText().toString();
            String unit = unitText.getText().toString();

            validateSettings(name, agency, unit);

            editor.putString("name", name);
            //editor.putString("phoneNumber", phoneNumber);
            editor.putString("agency", agency);
            editor.putString("unit", unit);
            editor.commit();
            finish();
        }
        catch(Exception e){
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle(getString(R.string.dialog_error))
                    .setIcon(R.drawable.novumicon)
                    .setMessage(e.getMessage());
            AlertDialog alertDialog = builder.create();
            alertDialog.setCancelable(true);
            alertDialog.setCanceledOnTouchOutside(true);
            alertDialog.show();
        }
    }

    /**
     * A placeholder fragment containing a simple view.
     */
    public static class PlaceholderFragment extends Fragment {

        public PlaceholderFragment() {
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                Bundle savedInstanceState) {
            View rootView = inflater.inflate(R.layout.fragment_settings, container, false);
            SharedPreferences preferences = rootView.getContext().getSharedPreferences(
                    String.valueOf(R.string.shared_pref_file), Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = preferences.edit();

            EditText nameText = (EditText)(rootView.findViewById(R.id.nameText));
            //EditText phoneNumberText = (EditText)(rootView.findViewById(R.id.phoneNumberText));
            EditText agencyText = (EditText)(rootView.findViewById(R.id.agencyText));
            EditText unitText = (EditText)(rootView.findViewById(R.id.unitText));

            String name = preferences.getString("name", "");
            String phoneNumber = preferences.getString("phoneNumber", "");
            String agency = preferences.getString("agency", "");
            String unit = preferences.getString("unit", "");

            nameText.setText(name);
            //phoneNumberText.setText(phoneNumber);
            agencyText.setText(agency);
            unitText.setText(unit);

            return rootView;
        }
    }

}
