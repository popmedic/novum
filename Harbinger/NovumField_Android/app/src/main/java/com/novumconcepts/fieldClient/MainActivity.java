package com.novumconcepts.fieldClient;

import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Debug;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.app.ActionBar;
import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.ContextMenu;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;
import android.view.ViewGroup;
import android.os.Build;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.entity.mime.content.ByteArrayBody;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.Console;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Array;
import java.net.URI;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Random;
import java.util.Set;

import static android.os.Environment.getExternalStoragePublicDirectory;

public class MainActivity extends ActionBarActivity {

    public static final int MEDIA_TYPE_IMAGE = 1;
    public static final int MEDIA_TYPE_VIDEO = 2;
    private static final int CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE = 100;
    private static final int PIC_MENU_ITEM_TAG_IDX = 1;
    private static final float REDUCE_PIC_SIZE = 1080f;
    private static final int REDUCE_PIC_QUALITY = 90;

    protected static final ArrayList<String> picFiles = new ArrayList<String>();
    protected static final IntegerStorage selectedBaseClient = new IntegerStorage(0);
    protected static final ArrayAdapterStorage<BaseClient> baseClients =
            new ArrayAdapterStorage<BaseClient>();
    protected static final IntegerStorage selectedAge = new IntegerStorage(0);
    protected static final ArrayAdapterStorage<String> ages =
            new ArrayAdapterStorage<String>();
    protected static final IntegerStorage selectedComplaint = new IntegerStorage(0);
    protected static final ArrayAdapterStorage<String> complaints=
            new ArrayAdapterStorage<String>();
    protected static final IntegerStorage selectedGenderId = new IntegerStorage(R.id.genderFemaleButton);
    protected static final UriStorage cameraFileUri = new UriStorage(null);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if(savedInstanceState != null){
            removePicFiles();
        }
        else{
            getSupportFragmentManager().beginTransaction()
                    .add(R.id.container, new MainFragment())
                    .commit();
        }

    }

    @Override
    protected void onSaveInstanceState (Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putStringArrayList("pic_files", picFiles);
        RadioGroup radioGroup = (RadioGroup)(findViewById(R.id.genderRadioGroup));
        selectedGenderId.setValue(radioGroup.getCheckedRadioButtonId());
    }

    @Override
    protected void onResume(){
        super.onResume();
        reloadImages();
        reloadSpinners();
        reloadRadios();
    }

    @Override
    protected void onDestroy(){
        super.onDestroy();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            Intent intent = new Intent(this, SettingsActivity.class);
            startActivity(intent);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onCreateContextMenu (ContextMenu menu, View v, ContextMenu.ContextMenuInfo menuInfo){
        menu.setHeaderTitle(getString(R.string.delete_question));
        int id = Integer.parseInt((String)v.getTag());
        menu.add(0, id, 0, getString(R.string.delete_comfirmation));
    }

    @Override
    public boolean onContextItemSelected(MenuItem item) {
        if(item.getTitle() == getString(R.string.delete_comfirmation)){
            int idx = item.getItemId();
            File file = new File(picFiles.get(idx));
            file.delete();
            picFiles.remove(idx);
            //savedBundle.putStringArrayList("pic_files", picFiles);
            reloadImages();
        }
        return true;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                if(cameraFileUri.value() != null) {
                    ExifInterface exif;
                    try { exif = new ExifInterface(cameraFileUri.value().getPath()); } catch (Exception e) { return; }
                    String exifOrientation = exif.getAttribute(ExifInterface.TAG_ORIENTATION);
                    Bitmap bitmap = BitmapFactory.decodeFile(cameraFileUri.value().getPath());
                    Matrix matrix = new Matrix();
                    if(Integer.parseInt(exifOrientation) == ExifInterface.ORIENTATION_ROTATE_90){
                        matrix.postRotate(90.0f, bitmap.getWidth() / 2, bitmap.getHeight() / 2);
                    }
                    else if(Integer.parseInt(exifOrientation) == ExifInterface.ORIENTATION_ROTATE_180){
                        matrix.postRotate(180.0f, bitmap.getWidth() / 2, bitmap.getHeight() / 2);
                    }
                    else if(Integer.parseInt(exifOrientation) == ExifInterface.ORIENTATION_ROTATE_270){
                        matrix.postRotate(270.0f, bitmap.getWidth() / 2, bitmap.getHeight() / 2);
                    }
                    float bmpRatio = 1.0f;
                    int bitmapHeight = bitmap.getHeight();
                    int bitmapWidth = bitmap.getWidth();
                    if(bitmapHeight > bitmapWidth){
                        bmpRatio = REDUCE_PIC_SIZE/(float)bitmapHeight;
                    }
                    else{
                        bmpRatio = REDUCE_PIC_SIZE/(float)bitmapWidth;
                    }
                    matrix.postScale(bmpRatio, bmpRatio);
                    Bitmap bitmapSmall = bitmap.createBitmap(bitmap, 0, 0, bitmapWidth,
                            bitmapHeight, matrix, true);
                    try {
                        FileOutputStream outputStream = new FileOutputStream(cameraFileUri.value().getPath());
                        bitmapSmall.compress(Bitmap.CompressFormat.JPEG, REDUCE_PIC_QUALITY, outputStream);
                        outputStream.close();
                        picFiles.add(cameraFileUri.value().getPath());
                    }
                    catch (Exception e){
                        AlertDialog.Builder builder = new AlertDialog.Builder(this);
                        builder.setIcon(R.drawable.novumicon).setTitle("ERROR").setMessage(e.getMessage());
                        AlertDialog alertDialog = builder.create();
                        alertDialog.setCancelable(true);
                        alertDialog.setCanceledOnTouchOutside(true);
                        alertDialog.show();
                    }
                }
                else{
                    AlertDialog.Builder builder = new AlertDialog.Builder(this);
                    builder.setIcon(R.drawable.novumicon).setTitle("ERROR").setMessage("Android bug: capture image returning a null file.");
                    AlertDialog alertDialog = builder.create();
                    alertDialog.setCancelable(true);
                    alertDialog.setCanceledOnTouchOutside(true);
                    alertDialog.show();
                }
            } else if (resultCode == RESULT_CANCELED) {
                // User cancelled the image capture
            } else {
                // Image capture failed, advise user
            }
        }

    }

    public void takePicButtonClick(View view){
        // create Intent to take a picture and return control to the calling application
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

        cameraFileUri.setValue(getOutputMediaFileUri(MEDIA_TYPE_IMAGE)); // create a file to save the image
        intent.putExtra(MediaStore.EXTRA_OUTPUT, cameraFileUri.value()); // set the image file name

        // start the image capture Intent
        startActivityForResult(intent, CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE);
    }

    public void sendButtonClick(View view){
        //send images and message via:
        SharedPreferences preferences = this.getSharedPreferences(
                String.valueOf(R.string.shared_pref_file), Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();

        String name = preferences.getString("name", "");
        String agency = preferences.getString("agency", "");
        String unit = preferences.getString("unit", "");
        String ui =  getString(R.string.app_ui);
        String mac_addr = getString(R.string.app_mac_addr);

        TelephonyManager tMgr = (TelephonyManager)getApplicationContext().getSystemService(Context.TELEPHONY_SERVICE);
        String phoneNumber = tMgr.getLine1Number();

        try{

            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(getString(R.string.novum_messagecenter_url));
            MultipartEntityBuilder multipartEntityBuilder = MultipartEntityBuilder.create();
            multipartEntityBuilder.setMode(HttpMultipartMode.BROWSER_COMPATIBLE);
            JSONObject vars = new JSONObject();

            vars.put("name", name);
            vars.put("phone_number", phoneNumber);
            vars.put("agency", agency);
            vars.put("unit", unit);
            vars.put("ui",ui);
            vars.put("mac_addr", mac_addr);

            Spinner spinner = (Spinner)findViewById(R.id.baseClientsSpinner);
            BaseClient selectedBC = (BaseClient)spinner.getSelectedItem();
            vars.put("to", String.valueOf(selectedBC.id));

            JSONObject jsonMessage = new JSONObject();
            RadioGroup radioGroup = (RadioGroup)(findViewById(R.id.genderRadioGroup));
            RadioButton radioButton = (RadioButton)findViewById(radioGroup.getCheckedRadioButtonId());
            jsonMessage.put("gender", radioButton.getText());
            spinner = (Spinner)findViewById(R.id.complaintSpinner);
            jsonMessage.put("complaint", spinner.getSelectedItem().toString());
            spinner = (Spinner)findViewById(R.id.ageSpinner);
            jsonMessage.put("age", spinner.getSelectedItem().toString());
            vars.put("message", jsonMessage.toString());

            validateMessage(vars);

            String varStr = vars.toString();
            multipartEntityBuilder.addTextBody("vars", varStr);

            int c = 1;
            for(int i = 0; i < picFiles.size(); i++){
                String path = picFiles.get(i);
                File file = new File(path);
                if(file.exists()){
                    String fn = "file" + String.valueOf(i+c);
                    multipartEntityBuilder.addPart(fn, new FileBody(file));
                }
                else{
                    c -= 1;
                }
            }

            httpPost.setEntity(multipartEntityBuilder.build());
            new SendMessageTask().execute(httpPost);
        }
        catch (Exception e){
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle(getString(R.string.dialog_error))
                    .setIcon(R.drawable.novumicon)
                    .setMessage(e.getMessage());
            AlertDialog alertDialog = builder.create();
            alertDialog.setCancelable(true);
            alertDialog.setCanceledOnTouchOutside(true);
            alertDialog.show();

            String msg = e.getLocalizedMessage();
            System.out.println(msg);
        }
    }

    private void removePicFiles(){
        if(picFiles.size() <= 0){
            File mediaStorageDir;
            mediaStorageDir = new File(getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_PICTURES), getString(R.string.app_picture_dir));
            if(mediaStorageDir.exists()){
                if(mediaStorageDir.isDirectory()){
                    String[] strings = mediaStorageDir.list();
                    for(int i = 0; i < strings.length; i++){
                        new File(mediaStorageDir, strings[i]).delete();
                    }
                }
            }
        }
    }
    /** reload radios */
    private void reloadRadios(){
        reloadGenderRadio();
    }
    private void reloadGenderRadio(){
        RadioButton radioButton = (RadioButton)findViewById(selectedGenderId.value());
        radioButton.setChecked(true);
    }

    /** reload spinners */
    private void reloadSpinners(){
        reloadBaseClientSpinner();
        reloadComplaintSpinner();
        reloadAgeSpinner();
    }
    private void reloadAgeSpinner(){
        final Spinner spinner = (Spinner)findViewById(R.id.ageSpinner);

        if(ages.getArrayAdapter() == null){
            ArrayAdapter<String> arrayAdapter = new ArrayAdapter<String>(this,
                    android.R.layout.simple_spinner_dropdown_item);
            arrayAdapter.add(getString(R.string.age));
            String[] strings = getResources().getStringArray(R.array.ages);
            for(int i = 0; i < strings.length; i++){
                arrayAdapter.add(strings[i]);
            }
            ages.setArrayAdapter(arrayAdapter);
        }

        spinner.setAdapter(ages.getArrayAdapter());
        spinner.setSelection(selectedComplaint.value());
        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parentView, View selectedItemView, int position, long id) {
                selectedAge.setValue(spinner.getSelectedItemPosition());
            }
            @Override public void onNothingSelected(AdapterView<?> adapterView) { }
        });
    }
    private void reloadBaseClientSpinner(){
        final Spinner bcSpinner = (Spinner)findViewById(R.id.baseClientsSpinner);

        if(baseClients.getArrayAdapter() == null){
            ArrayAdapter<BaseClient> bcs= new ArrayAdapter<BaseClient>(this,
                    android.R.layout.simple_spinner_dropdown_item);
            bcs.add(new BaseClient(0, getString(R.string.destination)));
            bcs.add(new BaseClient(1, "Novum Base"));
            bcs.add(new BaseClient(2, "PSL"));
            baseClients.setArrayAdapter(bcs);
        }

        bcSpinner.setAdapter(baseClients.getArrayAdapter());
        bcSpinner.setSelection(selectedBaseClient.value());
        bcSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parentView, View selectedItemView, int position, long id) {
                selectedBaseClient.setValue(bcSpinner.getSelectedItemPosition());
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {
            }
        });
    }
    private void reloadComplaintSpinner(){
        final Spinner ccSpinner = (Spinner)findViewById(R.id.complaintSpinner);

        if(complaints.getArrayAdapter() == null){
            ArrayAdapter<String> ca = new ArrayAdapter<String>(this,
                    android.R.layout.simple_spinner_dropdown_item);
            ca.add(getString(R.string.complaint));
            String[] cs = getResources().getStringArray(R.array.complaints);
            for(int i = 0; i < cs.length; i++){
                ca.add(cs[i]);
            }
            complaints.setArrayAdapter(ca);
        }

        ccSpinner.setAdapter(complaints.getArrayAdapter());
        ccSpinner.setSelection(selectedComplaint.value());
        ccSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parentView, View selectedItemView, int position, long id) {
                selectedComplaint.setValue(ccSpinner.getSelectedItemPosition());
            }
            @Override public void onNothingSelected(AdapterView<?> adapterView) { }
        });
    }

    /** reload the images */
    private void reloadImages(){
        LinearLayout linearLayout;

        String imgUriStr = null;
        Uri imgUri = null;
        ExifInterface exif = null;
        ImageView imageView = null;
        Bitmap bmpLarge = null;
        Bitmap bmpSmall = null;
        Matrix matrix = null;
        float bmpRatio = 0f;
        LinearLayout.LayoutParams imageParams = null;

        DisplayMetrics metrics;
        int pix;

        linearLayout = (LinearLayout)findViewById(R.id.imagesHorizontalLayout);
        linearLayout.removeAllViews();

        metrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(metrics);
        pix = (int) Math.ceil(64 * metrics.density);

        removePicFiles();

        for(int i = 0; i < picFiles.size(); i++){
            imgUriStr = picFiles.get(i);
            imgUri = Uri.parse(imgUriStr);

            imageView = new ImageView(this);
            imageView.setTag(Integer.toString(i));

            try { exif = new ExifInterface(imgUri.getPath()); } catch (Exception e) { return; }
            String exifOrientation = exif.getAttribute(ExifInterface.TAG_ORIENTATION);
            bmpLarge = BitmapFactory.decodeFile(imgUri.getPath());

            matrix = new Matrix();
            if(Integer.parseInt(exifOrientation) == ExifInterface.ORIENTATION_ROTATE_90){
                matrix.postRotate(90.0f, bmpLarge.getWidth() / 2, bmpLarge.getHeight() / 2);
            }
            else if(Integer.parseInt(exifOrientation) == ExifInterface.ORIENTATION_ROTATE_180){
                matrix.postRotate(180.0f, bmpLarge.getWidth() / 2, bmpLarge.getHeight() / 2);
            }
            else if(Integer.parseInt(exifOrientation) == ExifInterface.ORIENTATION_ROTATE_270){
                matrix.postRotate(270.0f, bmpLarge.getWidth() / 2, bmpLarge.getHeight() / 2);
            }

            if(bmpLarge.getHeight() > bmpLarge.getWidth()){
                bmpRatio = (float)pix/(float)bmpLarge.getHeight();
            }
            else{
                bmpRatio = (float)pix/(float)bmpLarge.getWidth();
            }
            matrix.postScale(bmpRatio, bmpRatio);

            bmpSmall = Bitmap.createBitmap(bmpLarge, 0, 0, bmpLarge.getWidth(),
                    bmpLarge.getHeight(), matrix, true);

            imageView.setImageBitmap(bmpSmall);

            imageParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT);
            //imageParams.bottomMargin = 8;
            imageParams.rightMargin = 8;

            registerForContextMenu(imageView);
            linearLayout.addView(imageView, imageParams);
        }
    }

    /** Create a file Uri for saving an image or video */
    private Uri getOutputMediaFileUri(int type){
        return Uri.fromFile(getOutputMediaFile(type));
    }

    /** Create a File for saving an image or video */
    private File getOutputMediaFile(int type){
        // To be safe, you should check that the SDCard is mounted
        // using Environment.getExternalStorageState() before doing this.

        File mediaStorageDir;
        mediaStorageDir = new File(getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES), getString(R.string.app_picture_dir));
        // This location works best if you want the created images to be shared
        // between applications and persist after your app has been uninstalled.

        // Create the storage directory if it does not exist
        if (! mediaStorageDir.exists()){
            if (! mediaStorageDir.mkdirs()){
                Log.d(getString(R.string.app_name), "failed to create directory");
                return null;
            }
        }
        mediaStorageDir.deleteOnExit();
        // Create a media file name
        String timeStamp = new SimpleDateFormat(getString(R.string.camera_img_datetime_fmt)).format(new Date());
        File mediaFile;
        if (type == MEDIA_TYPE_IMAGE){
            mediaFile = new File(mediaStorageDir.getPath() + File.separator +
                   getString(R.string.camera_img_prefix) + timeStamp + ".jpg");
            mediaFile.deleteOnExit();
        } else {
            return null;
        }

        return mediaFile;
    }

    private void validateMessage(JSONObject jsonObject) throws Exception{
        String to = jsonObject.getString("to");
        String name = jsonObject.getString("name");
        String agency = jsonObject.getString("agency");
        String unit = jsonObject.getString("unit");

        JSONObject jsonMessage = new JSONObject(jsonObject.getString("message"));
        String complaint = jsonMessage.getString("complaint");

        if(Integer.parseInt(to) == 0){
            throw new Exception(getString(R.string.validate_message_destination_failure));
        }
        else if(complaint.equals(getString(R.string.complaint))){
            throw new Exception(getString(R.string.validate_message_complaint_failure));
        }
        else if(name.equals("") || agency.equals("") || unit.equals("")){
            throw new Exception(getString(R.string.validate_message_settings_failure));
        }
    }

    class SendMessageTask extends AsyncTask<HttpUriRequest, Integer, String> {
        private Exception exception = null;
        ProgressDialog progressDialog;

        @Override
        protected String doInBackground(HttpUriRequest... httpUriRequests){
            String resultString = "";
            HttpClient httpClient = new DefaultHttpClient();
            try {
                HttpResponse httpResponse = httpClient.execute((HttpUriRequest)httpUriRequests[0]);
                InputStream is = httpResponse.getEntity().getContent();
                int i = -1;
                char c;
                while((i=is.read())!=-1)
                {
                    c=(char)i;
                    resultString += String.valueOf(c);
                }
            } catch (IOException e) {
                //e.printStackTrace();
                exception = e;
            }

            return resultString;
        }

        @Override
        protected void onPreExecute() {
            if (progressDialog == null) {
                progressDialog = new ProgressDialog(MainActivity.this);
                progressDialog.setMessage(getString(R.string.sending_message));
                progressDialog.setIcon(R.drawable.novumicon);
                progressDialog.show();
                progressDialog.setCanceledOnTouchOutside(false);
                progressDialog.setCancelable(false);
            }
        }

        @Override
        protected void onPostExecute(String result){

            if(progressDialog.isShowing()){

                progressDialog.dismiss();
                if(!result.equals("")){
                    AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
                    builder.setCancelable(true);
                    if(exception == null){
                        Spinner spinner = (Spinner)findViewById(R.id.baseClientsSpinner);

                        builder.setTitle(getString(R.string.sent_dialog_title_success))
                                .setIcon(R.drawable.novumicon)
                                .setCancelable(true)
                                .setMessage(getString(R.string.sent_dialog_message_prefix_success) +
                                        spinner.getSelectedItem().toString() + ".");

                        picFiles.removeAll(picFiles);
                        reloadImages();
                        selectedGenderId.setValue(R.id.genderFemaleButton);
                        reloadRadios();
                        spinner.setSelection(selectedBaseClient.value());
                        spinner = (Spinner)findViewById(R.id.complaintSpinner);
                        spinner.setSelection(0);
                        selectedComplaint.setValue(0);
                        spinner = (Spinner)findViewById(R.id.ageSpinner);
                        spinner.setSelection(0);
                        selectedAge.setValue(0);
                    }
                    else{
                        builder.setTitle(getString(R.string.sent_dialog_title_failure))
                                .setIcon(R.id.icon)
                                .setMessage(exception.getMessage());
                    }
                    AlertDialog alertDialog = builder.create();
                    alertDialog.setCanceledOnTouchOutside(true);
                    alertDialog.show();
                }
            }
        }
    }

    /** My class for holding a BaseClient */
    public static class BaseClient {
        public int id;
        public String name;
        public BaseClient(int _id, String _name){
            this.id = _id;
            this.name = _name;
        }

        @Override
        public String toString(){
            return name;
        }
    }

    public static class UriStorage{
        private Uri val;
        public UriStorage(Uri uri){
            val = uri;
        }
        public Uri value(){
            return val;
        }
        public void setValue(Uri uri){
            val = uri;
        }
    }

    public static class IntegerStorage{
        private Integer val;
        public IntegerStorage(int _val){
            val = _val;
        }
        public int value(){
            return val;
        }
        public String toString(){
            return val.toString();
        }
        public void setValue(int _val){
            val = _val;
        }
    }

    public static class ArrayAdapterStorage<T>{
        private ArrayAdapter<T> arrayAdapter;
        public ArrayAdapterStorage(){
            arrayAdapter = null;
        }
        public void setArrayAdapter(ArrayAdapter<T> _arrayAdapter){
            arrayAdapter = _arrayAdapter;
        }
        public ArrayAdapter<T> getArrayAdapter(){
            return arrayAdapter;
        }
    }
    /**
     * A main fragment containing the main view.
     */
    public static class MainFragment extends Fragment {
        public MainFragment() {

        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                                 Bundle savedInstanceState) {
            View rootView = inflater.inflate(R.layout.fragment_main, container, false);
            SharedPreferences preferences = rootView.getContext().getSharedPreferences(
                    String.valueOf(R.string.shared_pref_file), Context.MODE_PRIVATE);
            String name = preferences.getString("name", "");
            String agency = preferences.getString("agency", "");
            String unit = preferences.getString("unit", "");
            if(name.equals("") || agency.equals("") || unit.equals("")){
                Intent intent = new Intent(rootView.getContext(), SettingsActivity.class);
                startActivity(intent);
            }
            return rootView;
        }
    }
}
