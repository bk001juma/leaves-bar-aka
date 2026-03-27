<?php

namespace App\Helpers;

class ApiResponse
{

    public static function respond($data = null, $message = 'Success', $code = 200)
    {
        return response()->json([
            'code'    => $code,
            'status'  => $code === 200,
            'message' => $message,
            'data'    => $data,
        ], $code);
    }
}
